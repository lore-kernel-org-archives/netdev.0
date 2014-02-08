From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V2] staging: r8188eu: Fix missing header
Date: Fri,  7 Feb 2014 18:38:50 -0600
Message-ID: <1391819930-2549-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Commit 2397c6e0927675d983b34a03401affdb64818d07 entitled "staging: r8188eu:
Remove wrappers around vmalloc and vzalloc" and
commit: 03bd6aea7ba610a1a19f840c373624b8b0adde0d entitled "staging: r8188eu:
Remove wrappers around vfree" failed to add the header file needed
to provide vzalloc and vfree.

This problem was reported by the kbuild test robot.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

V2 - add attribution to the build robot
---

 drivers/staging/rtl8188eu/core/rtw_mlme.c      | 1 +
 drivers/staging/rtl8188eu/core/rtw_mp.c        | 1 +
 drivers/staging/rtl8188eu/core/rtw_recv.c      | 1 +
 drivers/staging/rtl8188eu/core/rtw_sta_mgt.c   | 1 +
 drivers/staging/rtl8188eu/core/rtw_xmit.c      | 1 +
 drivers/staging/rtl8188eu/os_dep/ioctl_linux.c | 1 +
 drivers/staging/rtl8188eu/os_dep/usb_intf.c    | 1 +
 7 files changed, 7 insertions(+)

diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme.c b/drivers/staging/rtl8188eu/core/rtw_mlme.c
index 2037be0..927fc72 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme.c
@@ -31,6 +31,7 @@
 #include <wlan_bssdef.h>
 #include <rtw_ioctl_set.h>
 #include <usb_osintf.h>
+#include <linux/vmalloc.h>
 
 extern unsigned char	MCS_rate_2R[16];
 extern unsigned char	MCS_rate_1R[16];
diff --git a/drivers/staging/rtl8188eu/core/rtw_mp.c b/drivers/staging/rtl8188eu/core/rtw_mp.c
index 9e97b57..99c06c4 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mp.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mp.c
@@ -23,6 +23,7 @@
 
 #include "odm_precomp.h"
 #include "rtl8188e_hal.h"
+#include <linux/vmalloc.h>
 
 u32 read_macreg(struct adapter *padapter, u32 addr, u32 sz)
 {
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index 8490d51..ed308ff 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -28,6 +28,7 @@
 #include <ethernet.h>
 #include <usb_ops.h>
 #include <wifi.h>
+#include <linux/vmalloc.h>
 
 static u8 SNAP_ETH_TYPE_IPX[2] = {0x81, 0x37};
 static u8 SNAP_ETH_TYPE_APPLETALK_AARP[2] = {0x80, 0xf3};
diff --git a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
index 6df9669..e8a654d 100644
--- a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
+++ b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
@@ -25,6 +25,7 @@
 #include <xmit_osdep.h>
 #include <mlme_osdep.h>
 #include <sta_info.h>
+#include <linux/vmalloc.h>
 
 static void _rtw_init_stainfo(struct sta_info *psta)
 {
diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index aa77270..2c0a40f 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -26,6 +26,7 @@
 #include <ip.h>
 #include <usb_ops.h>
 #include <usb_osintf.h>
+#include <linux/vmalloc.h>
 
 static u8 P802_1H_OUI[P80211_OUI_LEN] = { 0x00, 0x00, 0xf8 };
 static u8 RFC1042_OUI[P80211_OUI_LEN] = { 0x00, 0x00, 0x00 };
diff --git a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
index 0204082..f3584dd 100644
--- a/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/ioctl_linux.c
@@ -35,6 +35,7 @@
 
 #include <rtw_mp.h>
 #include <rtw_iol.h>
+#include <linux/vmalloc.h>
 
 #define RTL_IOCTL_WPA_SUPPLICANT	(SIOCIWFIRSTPRIV + 30)
 
diff --git a/drivers/staging/rtl8188eu/os_dep/usb_intf.c b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
index 0a585b2..8ad3948 100644
--- a/drivers/staging/rtl8188eu/os_dep/usb_intf.c
+++ b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
@@ -26,6 +26,7 @@
 #include <hal_intf.h>
 #include <rtw_version.h>
 #include <linux/usb.h>
+#include <linux/vmalloc.h>
 #include <osdep_intf.h>
 
 #include <usb_vendor_req.h>
-- 
1.8.4.5
