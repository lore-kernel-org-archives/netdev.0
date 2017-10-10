From: "Gustavo A. R. Silva" <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
Subject: [PATCH] rtl8xxxu: mark expected switch fall-throughs
Date: Tue, 10 Oct 2017 14:30:27 -0500
Message-ID: <20171010193027.GA23108@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "Gustavo A. R. Silva" <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
To: Jes Sorensen <Jes.Sorensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Cc: Jes Sorensen <Jes.Sorensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Gustavo A. R. Silva <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
---
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
index 7806a4d..e66be05 100644
--- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
+++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
@@ -1153,6 +1153,7 @@ void rtl8xxxu_gen1_config_channel(struct ieee80211_hw *hw)
 	switch (hw->conf.chandef.width) {
 	case NL80211_CHAN_WIDTH_20_NOHT:
 		ht = false;
+		/* fall through */
 	case NL80211_CHAN_WIDTH_20:
 		opmode |= BW_OPMODE_20MHZ;
 		rtl8xxxu_write8(priv, REG_BW_OPMODE, opmode);
@@ -1280,6 +1281,7 @@ void rtl8xxxu_gen2_config_channel(struct ieee80211_hw *hw)
 	switch (hw->conf.chandef.width) {
 	case NL80211_CHAN_WIDTH_20_NOHT:
 		ht = false;
+		/* fall through */
 	case NL80211_CHAN_WIDTH_20:
 		rf_mode_bw |= WMAC_TRXPTCL_CTL_BW_20;
 		subchannel = 0;
@@ -1748,9 +1750,11 @@ static int rtl8xxxu_identify_chip(struct rtl8xxxu_priv *priv)
 		case 3:
 			priv->ep_tx_low_queue = 1;
 			priv->ep_tx_count++;
+			/* fall through */
 		case 2:
 			priv->ep_tx_normal_queue = 1;
 			priv->ep_tx_count++;
+			/* fall through */
 		case 1:
 			priv->ep_tx_high_queue = 1;
 			priv->ep_tx_count++;
@@ -5691,6 +5695,7 @@ static int rtl8xxxu_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 		break;
 	case WLAN_CIPHER_SUITE_TKIP:
 		key->flags |= IEEE80211_KEY_FLAG_GENERATE_MMIC;
+		/* fall through */
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
2.7.4
