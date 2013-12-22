From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 02/31] staging: r8188eu: Replace wrapper rtw_yield_os
Date: Sun, 22 Dec 2013 17:36:33 -0600
Message-ID: <1387755422-11443-3-git-send-email-Larry.Finger@lwfinger.net>
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

a simple yield() is sufficient.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c     | 2 +-
 drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c      | 2 +-
 drivers/staging/rtl8188eu/include/osdep_service.h | 2 --
 drivers/staging/rtl8188eu/os_dep/osdep_service.c  | 5 -----
 4 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
index 9938e22..7c467ae 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
@@ -6333,7 +6333,7 @@ unsigned int send_beacon(struct adapter *padapter)
 		issue_beacon(padapter, 100);
 		issue++;
 		do {
-			rtw_yield_os();
+			yield();
 			rtw_hal_get_hwreg(padapter, HW_VAR_BCN_VALID, (u8 *)(&bxmitok));
 			poll++;
 		} while ((poll%10) != 0 && !bxmitok && !padapter->bSurpriseRemoved && !padapter->bDriverStopped);
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c b/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c
index b409b69..ca0a708 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c
@@ -655,7 +655,7 @@ _func_enter_;
 			SetFwRsvdPagePkt(adapt, false);
 			DLBcnCount++;
 			do {
-				rtw_yield_os();
+				yield();
 				/* mdelay(10); */
 				/*  check rsvd page download OK. */
 				rtw_hal_get_hwreg(adapt, HW_VAR_BCN_VALID, (u8 *)(&bcn_valid));
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 818bb91..00c349e 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -277,8 +277,6 @@ void rtw_sleep_schedulable(int ms);
 
 u32  rtw_atoi(u8 *s);
 
-void rtw_yield_os(void);
-
 static inline unsigned char _cancel_timer_ex(struct timer_list *ptimer)
 {
 	return del_timer_sync(ptimer);
diff --git a/drivers/staging/rtl8188eu/os_dep/osdep_service.c b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
index aedc016..2261342 100644
--- a/drivers/staging/rtl8188eu/os_dep/osdep_service.c
+++ b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
@@ -245,11 +245,6 @@ void rtw_sleep_schedulable(int ms)
 		return;
 }
 
-void rtw_yield_os(void)
-{
-	yield();
-}
-
 #define RTW_SUSPEND_LOCK_NAME "rtw_wifi"
 
 inline void rtw_suspend_lock_init(void)
-- 
1.8.4
