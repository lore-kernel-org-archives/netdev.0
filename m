From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 01/31] staging: r8188eu: Replace wrappers ODM_sleep_us and
 rtw_usleep_os
Date: Sun, 22 Dec 2013 17:36:32 -0600
Message-ID: <1387755422-11443-2-git-send-email-Larry.Finger@lwfinger.net>
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

Each of the uses in the code asks for a sleep of 100 usec or so. On Linux,
these are converted to msleep(1).

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_pwrctrl.c      |  2 +-
 drivers/staging/rtl8188eu/hal/odm_interface.c     |  6 ------
 drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c |  6 +++---
 drivers/staging/rtl8188eu/hal/rtl8188e_mp.c       | 16 ++++++++--------
 drivers/staging/rtl8188eu/include/odm_interface.h |  2 --
 drivers/staging/rtl8188eu/include/osdep_service.h |  2 --
 drivers/staging/rtl8188eu/os_dep/osdep_service.c  |  8 --------
 7 files changed, 12 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c b/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
index d5ad1dc..c011efe 100644
--- a/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
+++ b/drivers/staging/rtl8188eu/core/rtw_pwrctrl.c
@@ -396,7 +396,7 @@ s32 LPS_RF_ON_check(struct adapter *padapter, u32 delay_ms)
 			DBG_88E("%s: Wait for FW LPS leave more than %u ms!!!\n", __func__, delay_ms);
 			break;
 		}
-		rtw_usleep_os(100);
+		msleep(1);
 	}
 
 	return err;
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index e7fee79..780cb11 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -146,12 +146,6 @@ void ODM_IsWorkItemScheduled(void *pRtWorkItem)
 {
 }
 
-/*  ODM Timer relative API. */
-void ODM_sleep_us(u32 us)
-{
-	rtw_usleep_os(us);
-}
-
 void ODM_SetTimer(struct odm_dm_struct *pDM_Odm, struct timer_list *pTimer, u32 msDelay)
 {
 	_set_timer(pTimer, msDelay); /* ms */
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c b/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
index d81193b..5921db8 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
@@ -242,7 +242,7 @@ static void efuse_read_phymap_from_txpktbuf(
 		while (!(reg_0x143 = rtw_read8(adapter, REG_TXPKTBUF_DBG)) &&
 		       (passing_time = rtw_get_passing_time_ms(start)) < 1000) {
 			DBG_88E("%s polling reg_0x143:0x%02x, reg_0x106:0x%02x\n", __func__, reg_0x143, rtw_read8(adapter, 0x106));
-			rtw_usleep_os(100);
+			msleep(1);
 		}
 
 		lo32 = rtw_read32(adapter, REG_PKTBUF_DBG_DATA_L);
@@ -372,7 +372,7 @@ void rtw_IOL_cmd_tx_pkt_buf_dump(struct adapter *Adapter, int data_len)
 	if (pbuf) {
 		for (addr = 0; addr < data_cnts; addr++) {
 			rtw_write32(Adapter, 0x140, addr);
-			rtw_usleep_os(2);
+			msleep(1);
 			loop = 0;
 			do {
 				rstatus = (reg_140 = rtw_read32(Adapter, REG_PKTBUF_DBG_CTRL)&BIT24);
@@ -383,7 +383,7 @@ void rtw_IOL_cmd_tx_pkt_buf_dump(struct adapter *Adapter, int data_len)
 					fifo_data = rtw_read32(Adapter, REG_PKTBUF_DBG_DATA_H);
 					memcpy(pbuf+(addr*8+4), &fifo_data, 4);
 				}
-				rtw_usleep_os(2);
+				msleep(1);
 			} while (!rstatus && (loop++ < 10));
 		}
 		rtw_IOL_cmd_buf_dump(Adapter, data_len, pbuf);
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c b/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c
index ec4fb023..e5dc036 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c
@@ -663,18 +663,18 @@ void Hal_SetSingleToneTx(struct adapter *pAdapter, u8 bStart)
 
 		if (is92C) {
 			_write_rfreg(pAdapter, RF_PATH_A, 0x21, BIT19, 0x01);
-			rtw_usleep_os(100);
+			msleep(1);
 			if (rfPath == RF_PATH_A)
 				write_rfreg(pAdapter, RF_PATH_B, 0x00, 0x10000); /*  PAD all on. */
 			else if (rfPath == RF_PATH_B)
 				write_rfreg(pAdapter, RF_PATH_A, 0x00, 0x10000); /*  PAD all on. */
 			write_rfreg(pAdapter, rfPath, 0x00, 0x2001f); /*  PAD all on. */
-			rtw_usleep_os(100);
+			msleep(1);
 		} else {
 			write_rfreg(pAdapter, rfPath, 0x21, 0xd4000);
-			rtw_usleep_os(100);
+			msleep(1);
 			write_rfreg(pAdapter, rfPath, 0x00, 0x2001f); /*  PAD all on. */
-			rtw_usleep_os(100);
+			msleep(1);
 		}
 
 		/* for dynamic set Power index. */
@@ -696,15 +696,15 @@ void Hal_SetSingleToneTx(struct adapter *pAdapter, u8 bStart)
 		write_bbreg(pAdapter, rFPGA0_RFMOD, bOFDMEn, 0x1);
 		if (is92C) {
 			_write_rfreg(pAdapter, RF_PATH_A, 0x21, BIT19, 0x00);
-			rtw_usleep_os(100);
+			msleep(1);
 			write_rfreg(pAdapter, RF_PATH_A, 0x00, 0x32d75); /*  PAD all on. */
 			write_rfreg(pAdapter, RF_PATH_B, 0x00, 0x32d75); /*  PAD all on. */
-			rtw_usleep_os(100);
+			msleep(1);
 		} else {
 			write_rfreg(pAdapter, rfPath, 0x21, 0x54000);
-			rtw_usleep_os(100);
+			msleep(1);
 			write_rfreg(pAdapter, rfPath, 0x00, 0x30000); /*  PAD all on. */
-			rtw_usleep_os(100);
+			msleep(1);
 		}
 
 		/* Stop for dynamic set Power index. */
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index 5e05d9e..c088c85 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -135,8 +135,6 @@ void ODM_ScheduleWorkItem(void *pRtWorkItem);
 void ODM_IsWorkItemScheduled(void *pRtWorkItem);
 
 /*  ODM Timer relative API. */
-void ODM_sleep_us(u32 us);
-
 void ODM_SetTimer(struct odm_dm_struct *pDM_Odm, struct timer_list *pTimer,
 		  u32 msDelay);
 
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 6085181..818bb91 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -275,8 +275,6 @@ s32  rtw_get_time_interval_ms(u32 start, u32 end);
 
 void rtw_sleep_schedulable(int ms);
 
-void rtw_usleep_os(int us);
-
 u32  rtw_atoi(u8 *s);
 
 void rtw_yield_os(void);
diff --git a/drivers/staging/rtl8188eu/os_dep/osdep_service.c b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
index e62f120..aedc016 100644
--- a/drivers/staging/rtl8188eu/os_dep/osdep_service.c
+++ b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
@@ -245,14 +245,6 @@ void rtw_sleep_schedulable(int ms)
 		return;
 }
 
-void rtw_usleep_os(int us)
-{
-	if (1 < (us/1000))
-		msleep(1);
-	else
-		msleep((us/1000) + 1);
-}
-
 void rtw_yield_os(void)
 {
 	yield();
-- 
1.8.4
