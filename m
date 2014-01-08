From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v3.6 18/19] rtlwifi: slight optimization of addr compare
Date: Wed, 8 Jan 2014 10:54:23 +0800
Message-ID: <52CCBDDF.4050301@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use possibly more efficient ether_addr_equal_unaligned
instead of memcmp.

Cc: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Chaoming Li <chaoming_li@realsil.com.cn>
Cc: John W. Linville <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Weilong Chen <chenweilong@huawei.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/wireless/rtlwifi/cam.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/cam.c b/drivers/net/wireless/rtlwifi/cam.c
index 0e510f7..0276153 100644
--- a/drivers/net/wireless/rtlwifi/cam.c
+++ b/drivers/net/wireless/rtlwifi/cam.c
@@ -295,7 +295,7 @@ u8 rtl_cam_get_free_entry(struct ieee80211_hw *hw, u8 *sta_addr)
 	/* Does STA already exist? */
 	for (i = 4; i < TOTAL_CAM_ENTRY; i++) {
 		addr = rtlpriv->sec.hwsec_cam_sta_addr[i];
-		if (memcmp(addr, sta_addr, ETH_ALEN) == 0)
+		if (ether_addr_equal_unaligned(addr, sta_addr))
 			return i;
 	}
 	/* Get a free CAM entry. */
@@ -335,7 +335,7 @@ void rtl_cam_del_entry(struct ieee80211_hw *hw, u8 *sta_addr)
 		addr = rtlpriv->sec.hwsec_cam_sta_addr[i];
 		bitmap = (rtlpriv->sec.hwsec_cam_bitmap) >> i;
 		if (((bitmap & BIT(0)) == BIT(0)) &&
-		    (memcmp(addr, sta_addr, ETH_ALEN) == 0)) {
+		    (ether_addr_equal_unaligned(addr, sta_addr))) {
 			/* Remove from HW Security CAM */
 			eth_zero_addr(rtlpriv->sec.hwsec_cam_sta_addr[i]);
 			rtlpriv->sec.hwsec_cam_bitmap &= ~(BIT(0) << i);
-- 
1.8.0
