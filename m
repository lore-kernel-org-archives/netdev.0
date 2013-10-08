From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: rtl8192cu: Fix error in pointer arithmetic
Date: Tue,  8 Oct 2013 10:18:20 -0500
Message-ID: <1381245500-3920-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org,
	Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>,
	Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>

An error in calculating the offset in an skb causes the driver to read
essential device info from the wrong locations. The main effect is that
automatic gain calculations are nonsense.

Signed-off-by: Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org> [2.6.39+]
---
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
index 04c7e57..25e50ff 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
@@ -343,7 +343,8 @@ bool rtl92cu_rx_query_desc(struct ieee80211_hw *hw,
 					(bool)GET_RX_DESC_PAGGR(pdesc));
 	rx_status->mactime = GET_RX_DESC_TSFL(pdesc);
 	if (phystatus) {
-		p_drvinfo = (struct rx_fwinfo_92c *)(pdesc + RTL_RX_DESC_SIZE);
+		p_drvinfo = (struct rx_fwinfo_92c *)(skb->data +
+						     stats->rx_bufshift);
 		rtl92c_translate_rx_signal_stuff(hw, skb, stats, pdesc,
 						 p_drvinfo);
 	}
-- 
1.8.1.4
