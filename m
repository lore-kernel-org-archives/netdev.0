From: Andy Green <andy.green@linaro.org>
Subject: [PATCH 4 4/4] config test config extending omap2plus with wl12xx etc
Date: Thu, 05 Jul 2012 10:45:03 +0800
Message-ID: <20120705024501.26317.53085.stgit@build.warmcat.com>
References: <20120705024259.26317.16000.stgit@build.warmcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: s-jan@ti.com, arnd@arndb.de, patches@linaro.org, tony@atomide.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rostedt@goodmis.org, linux-arm-kernel@lists.infradead.org
To: linux-omap@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20120705024259.26317.16000.stgit@build.warmcat.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Green <andy@warmcat.com>

This is just provided for testing convenience, it has enough config
options to get Ethernet and WL12xx driver on PandaBoard / ES up

You should be able to reproduce something like this, with different
MAC addresses.

# ifconfig -a
eth0      Link encap:Ethernet  HWaddr 2e:20:3c:ea:46:01
          inet addr:10.42.0.98  Bcast:10.42.0.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:13 errors:0 dropped:0 overruns:0 frame:0
          TX packets:31 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1647 (1.6 KB)  TX bytes:5534 (5.5 KB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:2 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:100 (100.0 B)  TX bytes:100 (100.0 B)

wlan0     Link encap:Ethernet  HWaddr 2e:60:3c:ea:46:01
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

Signed-off-by: Andy Green <andy.green@linaro.org>
---
 arch/arm/configs/omap2plus_defconfig |   35 ++++++++++++++--------------------
 1 file changed, 14 insertions(+), 21 deletions(-)

diff --git a/arch/arm/configs/omap2plus_defconfig b/arch/arm/configs/omap2plus_defconfig
index f3087cb..7dcd384 100644
--- a/arch/arm/configs/omap2plus_defconfig
+++ b/arch/arm/configs/omap2plus_defconfig
@@ -2,13 +2,13 @@ CONFIG_EXPERIMENTAL=y
 CONFIG_SYSVIPC=y
 CONFIG_POSIX_MQUEUE=y
 CONFIG_BSD_PROCESS_ACCT=y
+CONFIG_NO_HZ=y
+CONFIG_HIGH_RES_TIMERS=y
 CONFIG_IKCONFIG=y
 CONFIG_IKCONFIG_PROC=y
 CONFIG_LOG_BUF_SHIFT=16
 CONFIG_BLK_DEV_INITRD=y
 CONFIG_EXPERT=y
-# CONFIG_SYSCTL_SYSCALL is not set
-CONFIG_KALLSYMS_EXTRA_PASS=y
 CONFIG_SLAB=y
 CONFIG_PROFILING=y
 CONFIG_OPROFILE=y
@@ -20,13 +20,12 @@ CONFIG_MODULE_FORCE_UNLOAD=y
 CONFIG_MODVERSIONS=y
 CONFIG_MODULE_SRCVERSION_ALL=y
 # CONFIG_BLK_DEV_BSG is not set
+CONFIG_PARTITION_ADVANCED=y
 CONFIG_ARCH_OMAP=y
 CONFIG_OMAP_RESET_CLOCKS=y
 CONFIG_OMAP_MUX_DEBUG=y
 CONFIG_ARM_THUMBEE=y
 CONFIG_ARM_ERRATA_411920=y
-CONFIG_NO_HZ=y
-CONFIG_HIGH_RES_TIMERS=y
 CONFIG_SMP=y
 CONFIG_NR_CPUS=2
 CONFIG_LEDS=y
@@ -60,6 +59,7 @@ CONFIG_BT_HCIUART_LL=y
 CONFIG_BT_HCIBCM203X=m
 CONFIG_BT_HCIBPA10X=m
 CONFIG_CFG80211=m
+CONFIG_LIB80211=m
 CONFIG_MAC80211=m
 CONFIG_MAC80211_RC_PID=y
 CONFIG_MAC80211_RC_DEFAULT_PID=y
@@ -87,22 +87,20 @@ CONFIG_SCSI_MULTI_LUN=y
 CONFIG_SCSI_SCAN_ASYNC=y
 CONFIG_MD=y
 CONFIG_NETDEVICES=y
-CONFIG_SMSC_PHY=y
-CONFIG_NET_ETHERNET=y
-CONFIG_SMC91X=y
-CONFIG_SMSC911X=y
 CONFIG_KS8851=y
 CONFIG_KS8851_MLL=y
-CONFIG_LIBERTAS=m
-CONFIG_LIBERTAS_USB=m
-CONFIG_LIBERTAS_SDIO=m
-CONFIG_LIBERTAS_DEBUG=y
+CONFIG_SMC91X=y
+CONFIG_SMSC911X=y
+CONFIG_SMSC_PHY=y
 CONFIG_USB_USBNET=y
 CONFIG_USB_NET_SMSC95XX=y
 CONFIG_USB_ALI_M5632=y
 CONFIG_USB_AN2720=y
 CONFIG_USB_EPSON2888=y
 CONFIG_USB_KC2190=y
+CONFIG_WL_TI=y
+CONFIG_WL12XX=m
+CONFIG_WLCORE_SDIO=m
 CONFIG_INPUT_JOYDEV=y
 CONFIG_INPUT_EVDEV=y
 CONFIG_KEYBOARD_GPIO=y
@@ -131,14 +129,14 @@ CONFIG_POWER_SUPPLY=y
 CONFIG_WATCHDOG=y
 CONFIG_OMAP_WATCHDOG=y
 CONFIG_TWL4030_WATCHDOG=y
-CONFIG_REGULATOR_TWL4030=y
+CONFIG_MFD_WL1273_CORE=y
 CONFIG_REGULATOR_TPS65023=y
 CONFIG_REGULATOR_TPS6507X=y
+CONFIG_REGULATOR_TWL4030=y
 CONFIG_FB=y
 CONFIG_FIRMWARE_EDID=y
 CONFIG_FB_MODE_HELPERS=y
 CONFIG_FB_TILEBLITTING=y
-CONFIG_FB_OMAP_LCD_VGA=y
 CONFIG_OMAP2_DSS=m
 CONFIG_OMAP2_DSS_RFBI=y
 CONFIG_OMAP2_DSS_SDI=y
@@ -153,7 +151,6 @@ CONFIG_PANEL_ACX565AKM=m
 CONFIG_BACKLIGHT_LCD_SUPPORT=y
 CONFIG_LCD_CLASS_DEVICE=y
 CONFIG_LCD_PLATFORM=y
-CONFIG_DISPLAY_SUPPORT=y
 CONFIG_FRAMEBUFFER_CONSOLE=y
 CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
 CONFIG_FONTS=y
@@ -173,7 +170,6 @@ CONFIG_SND_OMAP_SOC_OMAP3_PANDORA=m
 CONFIG_USB=y
 CONFIG_USB_DEBUG=y
 CONFIG_USB_ANNOUNCE_NEW_DEVICES=y
-CONFIG_USB_DEVICEFS=y
 CONFIG_USB_SUSPEND=y
 CONFIG_USB_MON=y
 CONFIG_USB_EHCI_HCD=y
@@ -212,23 +208,20 @@ CONFIG_JFFS2_RUBIN=y
 CONFIG_UBIFS_FS=y
 CONFIG_CRAMFS=y
 CONFIG_NFS_FS=y
-CONFIG_NFS_V3=y
 CONFIG_NFS_V3_ACL=y
 CONFIG_NFS_V4=y
 CONFIG_ROOT_NFS=y
-CONFIG_PARTITION_ADVANCED=y
 CONFIG_NLS_CODEPAGE_437=y
 CONFIG_NLS_ISO8859_1=y
 CONFIG_PRINTK_TIME=y
 CONFIG_MAGIC_SYSRQ=y
-CONFIG_DEBUG_KERNEL=y
 CONFIG_SCHEDSTATS=y
 CONFIG_TIMER_STATS=y
 CONFIG_PROVE_LOCKING=y
-CONFIG_DEBUG_SPINLOCK_SLEEP=y
 # CONFIG_DEBUG_BUGVERBOSE is not set
 CONFIG_DEBUG_INFO=y
-# CONFIG_RCU_CPU_STALL_DETECTOR is not set
+CONFIG_DEBUG_LL=y
+CONFIG_EARLY_PRINTK=y
 CONFIG_SECURITY=y
 CONFIG_CRYPTO_MICHAEL_MIC=y
 # CONFIG_CRYPTO_ANSI_CPRNG is not set

