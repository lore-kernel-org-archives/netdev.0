From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 6/6 NEXT] staging: r8723au: Turn on build of new driver
Date: Fri, 28 Mar 2014 21:37:43 -0500
Message-ID: <1396060663-3589-7-git-send-email-Larry.Finger@lwfinger.net>
References: <1396060663-3589-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Jes Sorensen <Jes.Sorensen@redhat.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:65459 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792AbaC2Cik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 22:38:40 -0400
Received: by mail-ob0-f180.google.com with SMTP id wn1so6661631obc.25
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 19:38:34 -0700 (PDT)
In-Reply-To: <1396060663-3589-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit also creates a TODO file.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Jes Sorensen <Jes.Sorensen@redhat.com>
---
 drivers/staging/Kconfig            |  2 ++
 drivers/staging/Makefile           |  1 +
 drivers/staging/rtl8723au/Kconfig  | 37 ++++++++++++++++++++++++
 drivers/staging/rtl8723au/Makefile | 58 ++++++++++++++++++++++++++++++++++++++
 drivers/staging/rtl8723au/TODO     | 13 +++++++++
 5 files changed, 111 insertions(+)
 create mode 100644 drivers/staging/rtl8723au/Kconfig
 create mode 100644 drivers/staging/rtl8723au/Makefile
 create mode 100644 drivers/staging/rtl8723au/TODO

diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index 99375f0..5a4d068 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -52,6 +52,8 @@ source "drivers/staging/rtl8712/Kconfig"
 
 source "drivers/staging/rtl8188eu/Kconfig"
 
+source "drivers/staging/rtl8723au/Kconfig"
+
 source "drivers/staging/rtl8821ae/Kconfig"
 
 source "drivers/staging/rts5139/Kconfig"
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index ddc3c4a..02a3639 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -18,6 +18,7 @@ obj-$(CONFIG_RTL8192U)		+= rtl8192u/
 obj-$(CONFIG_RTL8192E)		+= rtl8192e/
 obj-$(CONFIG_R8712U)		+= rtl8712/
 obj-$(CONFIG_R8188EU)		+= rtl8188eu/
+obj-$(CONFIG_R8723AU)		+= rtl8723au/
 obj-$(CONFIG_R8821AE)		+= rtl8821ae/
 obj-$(CONFIG_RTS5139)		+= rts5139/
 obj-$(CONFIG_RTS5208)		+= rts5208/
diff --git a/drivers/staging/rtl8723au/Kconfig b/drivers/staging/rtl8723au/Kconfig
new file mode 100644
index 0000000..7f19d15
--- /dev/null
+++ b/drivers/staging/rtl8723au/Kconfig
@@ -0,0 +1,37 @@
+config R8723AU
+	tristate "Realtek RTL8723AU Wireless LAN NIC driver"
+	depends on WLAN && USB
+	select WIRELESS_EXT
+	select WEXT_PRIV
+	default n
+	---help---
+	This option adds the Realtek RTL8723AU USB device such as found in
+	the Lenovo Yogi 13 tablet. If built as a module, it will be called r8723au.
+
+if R8723AU
+
+config 8723AU_AP_MODE
+	bool "Realtek RTL8723AU AP mode"
+	default y
+	---help---
+	This option enables Access Point mode. Unless you know that your system
+	will never be used as an AP, or the target system has limited memory,
+	"Y" should be selected.
+
+config 8723AU_P2P
+	bool "Realtek RTL8723AU Peer-to-peer mode"
+	default y
+	---help---
+	This option enables peer-to-peer mode for the r8723au driver. Unless you
+	know that peer-to-peer (P2P) mode will never be used, or the target system has
+	limited memory, "Y" should be selected.
+
+config 8723AU_BT_COEXIST
+	bool "Realtek RTL8723AU BlueTooth Coexistence"
+	default y
+	---help---
+	This option enables icoexistence with BlueTooth communications for the r8723au driver.
+	Unless you know that this driver will never by used with BT, or the target system has
+	limited memory, "Y" should be selected.
+
+endif
diff --git a/drivers/staging/rtl8723au/Makefile b/drivers/staging/rtl8723au/Makefile
new file mode 100644
index 0000000..11c6dd4
--- /dev/null
+++ b/drivers/staging/rtl8723au/Makefile
@@ -0,0 +1,58 @@
+r8723au-y :=				\
+		core/rtw_ap.o		\
+		core/rtw_cmd.o		\
+		core/rtw_efuse.o	\
+		core/rtw_io.o		\
+		core/rtw_ioctl_set.o	\
+		core/rtw_ieee80211.o	\
+		core/rtw_led.o		\
+		core/rtw_mlme.o		\
+		core/rtw_mlme_ext.o	\
+		core/rtw_p2p.o		\
+		core/rtw_pwrctrl.o	\
+		core/rtw_recv.o		\
+		core/rtw_security.o	\
+		core/rtw_sreset.o	\
+		core/rtw_sta_mgt.o	\
+		core/rtw_xmit.o		\
+		core/rtw_wlan_util.o	\
+		hal/hal_com.o		\
+		hal/hal_intf.o		\
+		hal/Hal8723PwrSeq.o	\
+		hal/Hal8723UHWImg_CE.o	\
+		hal/HalDMOutSrc8723A_CE.o \
+		hal/HalHWImg8723A_BB.o	\
+		hal/HalHWImg8723A_MAC.o	\
+		hal/HalHWImg8723A_RF.o	\
+		hal/HalPwrSeqCmd.o	\
+		hal/odm_RegConfig8723A.o \
+		hal/rtl8723a_bt-coexist.o \
+		hal/odm_debug.o		\
+		hal/odm_interface.o	\
+		hal/odm_HWConfig.o	\
+		hal/odm.o		\
+		hal/rtl8723a_cmd.o	\
+		hal/rtl8723a_dm.o	\
+		hal/rtl8723a_hal_init.o	\
+		hal/rtl8723a_phycfg.o	\
+		hal/rtl8723a_rf6052.o	\
+		hal/rtl8723a_rxdesc.o	\
+		hal/rtl8723a_sreset.o	\
+		hal/rtl8723a_xmit.o	\
+		hal/rtl8723au_led.o	\
+		hal/rtl8723au_recv.o	\
+		hal/rtl8723au_xmit.o	\
+		hal/usb_halinit.o	\
+		hal/usb_ops_linux.o	\
+		os_dep/ioctl_cfg80211.o	\
+		os_dep/mlme_linux.o	\
+		os_dep/osdep_service.o	\
+		os_dep/os_intfs.o	\
+		os_dep/recv_linux.o	\
+		os_dep/usb_intf.o	\
+		os_dep/usb_ops_linux.o	\
+		os_dep/xmit_linux.o
+
+obj-$(CONFIG_R8723AU)	:= r8723au.o
+
+ccflags-y += -D__CHECK_ENDIAN__ -I$(src)/include
diff --git a/drivers/staging/rtl8723au/TODO b/drivers/staging/rtl8723au/TODO
new file mode 100644
index 0000000..175a0ce
--- /dev/null
+++ b/drivers/staging/rtl8723au/TODO
@@ -0,0 +1,13 @@
+TODO:
+- find and remove code valid only for 5 HGz. Many of the obvious
+  ones have been removed, but things like channel > 14 still exist.
+- find and remove any code for other chips that is left over
+- convert any remaining unusual variable types
+- find codes that can use %pM and %Nph formatting
+- checkpatch.pl fixes - most of the remaining ones are lines too long. Many
+  of them will require refactoring
+- merge Realtek's bugfixes and new features into the driver
+- switch to use MAC80211
+
+Please send any patches to Greg Kroah-Hartman <gregkh@linux.com>,
+Jes Sorensen <Jes.Sorensen@redhat.com>, and Larry Finger <Larry.Finger@lwfinger.net>.
-- 
1.8.4.5
