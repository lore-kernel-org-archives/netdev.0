From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] staging: r8723au: Fix build warnings
Date: Wed,  9 Apr 2014 10:05:20 -0500
Message-ID: <1397055920-11654-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Jes Sorensen <Jes.Sorensen@redhat.com>, kbuild-all@01.org,
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

The kbuild test robot reports the following:

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   75ff24fa52f0cc512ceee4c377632b91a3a80811
commit: 9176303c404741b2f96796466437f2badf6e289b staging: r8723au: Turn on build of new driver
date:   4 days ago
config: make ARCH=avr32 allyesconfig

All warnings:

>> drivers/staging/rtl8723au/include/rtw_mlme.h:620: warning: 'rtw_set_roaming' declared inline after being called
   drivers/staging/rtl8723au/include/rtw_mlme.h:620: warning: previous declaration of 'rtw_set_roaming' was here
>> drivers/staging/rtl8723au/include/rtw_mlme.h:621: warning: 'rtw_to_roaming' declared inline after being called
   drivers/staging/rtl8723au/include/rtw_mlme.h:621: warning: previous declaration of 'rtw_to_roaming' was here
--
   drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c: In function 'Hal_EEValueCheck':
>> drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c:2277: warning: comparison is always true due to limited range of data type

The first two warnings are fixed by making the two prototypes be "inline" to match
the actual routine. The third warning comes from testing that a u8 quantity is positive.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Jes Sorensen <Jes.Sorensen@redhat.com>
Cc: kbuild-all@01.org
---
 drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c | 2 +-
 drivers/staging/rtl8723au/include/rtw_mlme.h      | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c b/drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c
index 0a86923..dae61af 100644
--- a/drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c
+++ b/drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c
@@ -2277,7 +2277,7 @@ static void Hal_EEValueCheck(u8 EEType, void *pInValue, void *pOutValue)
 		u8 *pIn, *pOut;
 		pIn = (u8 *) pInValue;
 		pOut = (u8 *) pOutValue;
-		if (*pIn >= 0 && *pIn <= 63) {
+		if (*pIn <= 63) {
 			*pOut = *pIn;
 		} else {
 			RT_TRACE(_module_hci_hal_init_c_, _drv_err_,
diff --git a/drivers/staging/rtl8723au/include/rtw_mlme.h b/drivers/staging/rtl8723au/include/rtw_mlme.h
index 2d4f61b..3457b96 100644
--- a/drivers/staging/rtl8723au/include/rtw_mlme.h
+++ b/drivers/staging/rtl8723au/include/rtw_mlme.h
@@ -616,7 +616,7 @@ void _rtw23a_roaming(struct rtw_adapter *adapter,
 		  struct wlan_network *tgt_network);
 void rtw23a_roaming(struct rtw_adapter *adapter,
 		 struct wlan_network *tgt_network);
-void rtw_set_roaming(struct rtw_adapter *adapter, u8 to_roaming);
-u8 rtw_to_roaming(struct rtw_adapter *adapter);
+inline void rtw_set_roaming(struct rtw_adapter *adapter, u8 to_roaming);
+inline u8 rtw_to_roaming(struct rtw_adapter *adapter);
 
 #endif /* __RTL871X_MLME_H_ */
-- 
1.8.1.4
