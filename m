From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 03/31] staging: r8188eu: Remove wrapper code for
 rtw_suspend_lock_init, rtw_suspend_lock_uninit, rtw_lock_suspend,
 and rtw_unlock_suspend
Date: Sun, 22 Dec 2013 17:36:34 -0600
Message-ID: <1387755422-11443-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
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

All of these routines are empty.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/include/osdep_service.h |  5 -----
 drivers/staging/rtl8188eu/os_dep/osdep_service.c  | 16 ----------------
 drivers/staging/rtl8188eu/os_dep/rtw_android.c    |  2 --
 drivers/staging/rtl8188eu/os_dep/usb_intf.c       |  4 ----
 4 files changed, 27 deletions(-)

diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 00c349e..091ca4b 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -357,11 +357,6 @@ static inline u32 bitshift(u32 bitmask)
 /*  limitation of path length */
 #define PATH_LENGTH_MAX PATH_MAX
 
-void rtw_suspend_lock_init(void);
-void rtw_suspend_lock_uninit(void);
-void rtw_lock_suspend(void);
-void rtw_unlock_suspend(void);
-
 /* Atomic integer operations */
 #define ATOMIC_T atomic_t
 
diff --git a/drivers/staging/rtl8188eu/os_dep/osdep_service.c b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
index 2261342..9c3e410 100644
--- a/drivers/staging/rtl8188eu/os_dep/osdep_service.c
+++ b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
@@ -247,22 +247,6 @@ void rtw_sleep_schedulable(int ms)
 
 #define RTW_SUSPEND_LOCK_NAME "rtw_wifi"
 
-inline void rtw_suspend_lock_init(void)
-{
-}
-
-inline void rtw_suspend_lock_uninit(void)
-{
-}
-
-inline void rtw_lock_suspend(void)
-{
-}
-
-inline void rtw_unlock_suspend(void)
-{
-}
-
 inline void ATOMIC_SET(ATOMIC_T *v, int i)
 {
 	atomic_set(v, i);
diff --git a/drivers/staging/rtl8188eu/os_dep/rtw_android.c b/drivers/staging/rtl8188eu/os_dep/rtw_android.c
index 6cf71cc..a3c2bc5 100644
--- a/drivers/staging/rtl8188eu/os_dep/rtw_android.c
+++ b/drivers/staging/rtl8188eu/os_dep/rtw_android.c
@@ -159,7 +159,6 @@ int rtw_android_priv_cmd(struct net_device *net, struct ifreq *ifr, int cmd)
 	int bytes_written = 0;
 	struct android_wifi_priv_cmd priv_cmd;
 
-	rtw_lock_suspend();
 	if (!ifr->ifr_data) {
 		ret = -EINVAL;
 		goto exit;
@@ -287,7 +286,6 @@ response:
 		ret = bytes_written;
 	}
 exit:
-	rtw_unlock_suspend();
 	kfree(command);
 	return ret;
 }
diff --git a/drivers/staging/rtl8188eu/os_dep/usb_intf.c b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
index 527d4e7..28903aa 100644
--- a/drivers/staging/rtl8188eu/os_dep/usb_intf.c
+++ b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
@@ -867,8 +867,6 @@ static int __init rtw_drv_entry(void)
 	DBG_88E(DRV_NAME " driver version=%s\n", DRIVERVERSION);
 	DBG_88E("build time: %s %s\n", __DATE__, __TIME__);
 
-	rtw_suspend_lock_init();
-
 	_rtw_mutex_init(&usb_drv->hw_init_mutex);
 
 	usb_drv->drv_registered = true;
@@ -880,8 +878,6 @@ static void __exit rtw_drv_halt(void)
 	RT_TRACE(_module_hci_intfs_c_, _drv_err_, ("+rtw_drv_halt\n"));
 	DBG_88E("+rtw_drv_halt\n");
 
-	rtw_suspend_lock_uninit();
-
 	usb_drv->drv_registered = false;
 	usb_deregister(&usb_drv->usbdrv);
 
-- 
1.8.4
