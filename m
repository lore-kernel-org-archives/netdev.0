From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V2] staging: rtl8192ee: Fix setting highest n rate
Date: Wed, 16 Jul 2014 22:03:09 -0500
Message-ID: <1405566189-16281-1-git-send-email-Larry.Finger@lwfinger.net>
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

Commit 4fb6a37c3f94c1cb4b828bfcc4347771e1628f88 by Andrey Utkin
<andrey.krieger.utkin@gmail.com> and entitled "staging: rtl8192ee:
"Correct bitmask in comparsion" fixed what appeared to be a typo. After
consultation with the Realtek engineers, merely testing for a 2T2R device
is sufficient to ensure that the TX MCS map will equal 0x0c, thus the second
test can be ignored.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

V2 - Remove extraneous parenthesis

 drivers/staging/rtl8192ee/base.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/staging/rtl8192ee/base.c b/drivers/staging/rtl8192ee/base.c
index 71ed12e..b8b897a 100644
--- a/drivers/staging/rtl8192ee/base.c
+++ b/drivers/staging/rtl8192ee/base.c
@@ -826,8 +826,7 @@ static u8 _rtl_get_vht_highest_n_rate(struct ieee80211_hw *hw,
 	u8 hw_rate;
 	u16 map = le16_to_cpu(sta->vht_cap.vht_mcs.tx_mcs_map);
 
-	if ((get_rf_type(rtlphy) == RF_2T2R) &&
-	    (map & 0x000c) != 0x000c) {
+	if (get_rf_type(rtlphy) == RF_2T2R) {
 		if ((map & 0x000c) >> 2 == IEEE80211_VHT_MCS_SUPPORT_0_7)
 			hw_rate =
 			rtlpriv->cfg->maps[RTL_RC_VHT_RATE_2SS_MCS7];
-- 
1.8.4.5
