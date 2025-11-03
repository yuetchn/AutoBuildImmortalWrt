#!/bin/bash
# Log file for debugging
source shell/custom-packages.sh
echo "第三方软件包: $CUSTOM_PACKAGES"
LOGFILE="/tmp/uci-defaults-log.txt"
echo "Starting 99-custom.sh at $(date)" >> $LOGFILE
echo "编译固件大小为: $PROFILE MB"
echo "Include Docker: $INCLUDE_DOCKER"

echo "Create pppoe-settings"
mkdir -p  /home/build/immortalwrt/files/etc/config

# 创建pppoe配置文件 yml传入环境变量ENABLE_PPPOE等 写入配置文件 供99-custom.sh读取
cat << EOF > /home/build/immortalwrt/files/etc/config/pppoe-settings
enable_pppoe=${ENABLE_PPPOE}
pppoe_account=${PPPOE_ACCOUNT}
pppoe_password=${PPPOE_PASSWORD}
EOF

echo "cat pppoe-settings"
cat /home/build/immortalwrt/files/etc/config/pppoe-settings

if [ -z "$CUSTOM_PACKAGES" ]; then
  echo "⚪️ 未选择 任何第三方软件包"
else
  # ============= 同步第三方插件库==============
  # 同步第三方软件仓库run/ipk
  echo "🔄 正在同步第三方软件仓库 Cloning run file repo..."
  git clone --depth=1 https://github.com/wukongdaily/store.git /tmp/store-run-repo

  # 拷贝 run/x86 下所有 run 文件和ipk文件 到 extra-packages 目录
  mkdir -p /home/build/immortalwrt/extra-packages
  cp -r /tmp/store-run-repo/run/x86/* /home/build/immortalwrt/extra-packages/

  echo "✅ Run files copied to extra-packages:"
  ls -lh /home/build/immortalwrt/extra-packages/*.run
  # 解压并拷贝ipk到packages目录
  sh shell/prepare-packages.sh
  ls -lah /home/build/immortalwrt/packages/
fi

# 输出调试信息
echo "$(date '+%Y-%m-%d %H:%M:%S') - 开始构建固件..."

# ============= imm仓库内的插件==============
# 定义所需安装的包列表 下列插件你都可以自行删减
PACKAGES=""
PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES luci-i18n-diskman-zh-cn"
PACKAGES="$PACKAGES luci-i18n-firewall-zh-cn"
PACKAGES="$PACKAGES luci-theme-argon"
PACKAGES="$PACKAGES luci-app-argon-config"
PACKAGES="$PACKAGES luci-i18n-argon-config-zh-cn"
#24.10
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn"
PACKAGES="$PACKAGES luci-i18n-ttyd-zh-cn"
PACKAGES="$PACKAGES luci-i18n-passwall-zh-cn"
PACKAGES="$PACKAGES luci-app-openclash"
PACKAGES="$PACKAGES luci-i18n-homeproxy-zh-cn"
PACKAGES="$PACKAGES openssh-sftp-server"
PACKAGES="$PACKAGES luci-i18n-samba4-zh-cn"
# 文件管理器
PACKAGES="$PACKAGES luci-i18n-filemanager-zh-cn"
# 静态文件服务器dufs(推荐)
PACKAGES="$PACKAGES luci-i18n-dufs-zh-cn"

# Ath9k 无线网卡
PACKAGES="$PACKAGES ath9k-htc-firmware"
PACKAGES="$PACKAGES kmod-ath9k"
PACKAGES="$PACKAGES kmod-ath9k-common"
PACKAGES="$PACKAGES kmod-ath9k-htc"

# 8168网卡以及其他网卡
PACKAGES="$PACKAGES r8169-firmware"
PACKAGES="$PACKAGES kmod-r8101"
PACKAGES="$PACKAGES kmod-r8125"
PACKAGES="$PACKAGES kmod-r8126"
PACKAGES="$PACKAGES kmod-r8127"
PACKAGES="$PACKAGES kmod-r8168"
PACKAGES="$PACKAGES kmod-r8169"

# USB 以及 USB网络共享
PACKAGES="$PACKAGES kmod-usb-core"
PACKAGES="$PACKAGES kmod-usb-ehci"
PACKAGES="$PACKAGES kmod-usb-hid"
PACKAGES="$PACKAGES kmod-usb-ledtrig-usbport"
PACKAGES="$PACKAGES kmod-usb-net"
PACKAGES="$PACKAGES kmod-usb-net-ipheth"
PACKAGES="$PACKAGES kmod-usb-serial-option"
PACKAGES="$PACKAGES kmod-usb-uhci"
PACKAGES="$PACKAGES kmod-usb2"
PACKAGES="$PACKAGES kmod-usbip"
PACKAGES="$PACKAGES kmod-usbip-client"
PACKAGES="$PACKAGES kmod-usbip-server"
PACKAGES="$PACKAGES kmod-usbmon"

PACKAGES="$PACKAGES kmod-usb-net-rndis"
PACKAGES="$PACKAGES kmod-usb-storage"
PACKAGES="$PACKAGES usbmuxd"
PACKAGES="$PACKAGES libimobiledevice"
PACKAGES="$PACKAGES usbutils"

# ======== 其他自定义软件 =========
PACKAGES="$PACKAGES luci"
PACKAGES="$PACKAGES luci-compat"
PACKAGES="$PACKAGES luci-mod-network"
PACKAGES="$PACKAGES luci-mod-status"
PACKAGES="$PACKAGES luci-mod-system"
PACKAGES="$PACKAGES luci-app-acl"
PACKAGES="$PACKAGES luci-app-adblock"
PACKAGES="$PACKAGES luci-app-adblock-fast"
PACKAGES="$PACKAGES luci-app-advanced-reboot"
PACKAGES="$PACKAGES luci-app-airplay2"
PACKAGES="$PACKAGES luci-app-antiblock"
PACKAGES="$PACKAGES luci-app-argon-config"
PACKAGES="$PACKAGES luci-app-aria2"
PACKAGES="$PACKAGES luci-app-arpbind"
PACKAGES="$PACKAGES luci-app-attendedsysupgrade"
PACKAGES="$PACKAGES luci-app-autoreboot"
PACKAGES="$PACKAGES luci-app-banip"
PACKAGES="$PACKAGES luci-app-cd8021x"
PACKAGES="$PACKAGES luci-app-cifs-mount"
PACKAGES="$PACKAGES luci-app-dawn"
PACKAGES="$PACKAGES luci-app-ddns"
PACKAGES="$PACKAGES luci-app-diskman"
PACKAGES="$PACKAGES luci-app-dufs"
PACKAGES="$PACKAGES luci-app-dynapoint"
PACKAGES="$PACKAGES luci-app-filebrowser"
PACKAGES="$PACKAGES luci-app-filemanager"
PACKAGES="$PACKAGES luci-app-firewall"
PACKAGES="$PACKAGES luci-app-frpc"
PACKAGES="$PACKAGES luci-app-natmap"
PACKAGES="$PACKAGES luci-app-netdata"
PACKAGES="$PACKAGES luci-app-nfs"
PACKAGES="$PACKAGES luci-app-oled"
PACKAGES="$PACKAGES luci-app-package-manager"
PACKAGES="$PACKAGES luci-app-qbittorrent"
PACKAGES="$PACKAGES luci-app-qos"
PACKAGES="$PACKAGES luci-app-ttyd"
PACKAGES="$PACKAGES luci-app-v2raya"
PACKAGES="$PACKAGES luci-theme-argon"
PACKAGES="$PACKAGES luci-theme-bootstrap"
PACKAGES="$PACKAGES luci-theme-material"
PACKAGES="$PACKAGES luci-theme-openwrt"
PACKAGES="$PACKAGES luci-theme-openwrt-2020"
PACKAGES="$PACKAGES luci-proto-ipv6"
PACKAGES="$PACKAGES luci-lib-ip"
PACKAGES="$PACKAGES luci-lib-ipkg"
PACKAGES="$PACKAGES luci-i18n-acl-zh-cn"
PACKAGES="$PACKAGES luci-i18n-adblock-fast-zh-cn"
PACKAGES="$PACKAGES luci-i18n-adblock-zh-cn"
PACKAGES="$PACKAGES luci-i18n-advanced-reboot-zh-cn"
PACKAGES="$PACKAGES luci-i18n-airplay2-zh-cn"
PACKAGES="$PACKAGES luci-i18n-argon-config-zh-cn"
PACKAGES="$PACKAGES luci-i18n-aria2-zh-cn"
PACKAGES="$PACKAGES luci-i18n-arpbind-zh-cn"
PACKAGES="$PACKAGES luci-i18n-attendedsysupgrade-zh-cn"
PACKAGES="$PACKAGES luci-i18n-autoreboot-zh-cn"
PACKAGES="$PACKAGES luci-i18n-banip-zh-cn"
PACKAGES="$PACKAGES luci-i18n-cd8021x-zh-cn"
PACKAGES="$PACKAGES luci-i18n-cifs-mount-zh-cn"
PACKAGES="$PACKAGES luci-i18n-dawn-zh-cn"
PACKAGES="$PACKAGES luci-i18n-ddns-zh-cn"
PACKAGES="$PACKAGES luci-i18n-diskman-zh-cn"
PACKAGES="$PACKAGES luci-i18n-dufs-zh-cn"
PACKAGES="$PACKAGES luci-i18n-dynapoint-zh-cn"
PACKAGES="$PACKAGES luci-i18n-filebrowser-zh-cn"
PACKAGES="$PACKAGES luci-i18n-filemanager-zh-cn"
PACKAGES="$PACKAGES luci-i18n-firewall-zh-cn"
PACKAGES="$PACKAGES luci-i18n-frpc-zh-cn"
PACKAGES="$PACKAGES luci-i18n-natmap-zh-cn"
PACKAGES="$PACKAGES luci-i18n-netdata-zh-cn"
PACKAGES="$PACKAGES luci-i18n-nfs-zh-cn"
PACKAGES="$PACKAGES luci-i18n-oled-zh-cn"
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn"
PACKAGES="$PACKAGES luci-i18n-qbittorrent-zh-cn"
PACKAGES="$PACKAGES luci-i18n-qos-zh-cn"
PACKAGES="$PACKAGES luci-i18n-ttyd-zh-cn"
PACKAGES="$PACKAGES luci-i18n-v2raya-zh-cn"
PACKAGES="$PACKAGES luci-i18n-wifischedule-zh-cn"

# ======== shell/custom-packages.sh =======
# 合并imm仓库以外的第三方插件
PACKAGES="$PACKAGES $CUSTOM_PACKAGES"


# 判断是否需要编译 Docker 插件
if [ "$INCLUDE_DOCKER" = "yes" ]; then
    PACKAGES="$PACKAGES luci-i18n-dockerman-zh-cn"
    echo "Adding package: luci-i18n-dockerman-zh-cn"
fi

# 若构建openclash 则添加内核
if echo "$PACKAGES" | grep -q "luci-app-openclash"; then
    echo "✅ 已选择 luci-app-openclash，添加 openclash core"
    mkdir -p files/etc/openclash/core
    # Download clash_meta
    META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64.tar.gz"
    wget -qO- $META_URL | tar xOvz > files/etc/openclash/core/clash_meta
    chmod +x files/etc/openclash/core/clash_meta
    # Download GeoIP and GeoSite
    wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -O files/etc/openclash/GeoIP.dat
    wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -O files/etc/openclash/GeoSite.dat
else
    echo "⚪️ 未选择 luci-app-openclash"
fi

# 构建镜像
echo "$(date '+%Y-%m-%d %H:%M:%S') - Building image with the following packages:"
echo "$PACKAGES"

make image PROFILE="generic" PACKAGES="$PACKAGES" FILES="/home/build/immortalwrt/files" ROOTFS_PARTSIZE=$PROFILE

if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Build failed!"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."
