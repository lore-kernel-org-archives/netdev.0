From: Markus Pargmann <mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH RESEND] mwifiex: Remove custom world regulatory domain
Date: Sat, 28 Jun 2014 15:49:13 +0200
Message-ID: <1403963353-27317-1-git-send-email-mpa@pengutronix.de>
Cc: Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	Markus Pargmann <mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A custom regulatory domain was introduced in this commit:
cc0ba0d522c4 (mwifiex: support custom world regulatory domain)

The commit description says that it was introduced because the world
regulatory domain does not include channels 52-64 and 100-140. These
channels are described in the world regulatory domain now, so we can
drop this custom regulatory domain.

Signed-off-by: Markus Pargmann <mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Acked-by: Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/mwifiex/cfg80211.c | 36 ---------------------------------
 1 file changed, 36 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/mwifiex/cfg80211.c
index e95dec91a561..201edbf76c81 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -42,36 +42,6 @@ static const struct ieee80211_iface_combination mwifiex_iface_comb_ap_sta = {
 	.beacon_int_infra_match = true,
 };
 
-static const struct ieee80211_regdomain mwifiex_world_regdom_custom = {
-	.n_reg_rules = 7,
-	.alpha2 =  "99",
-	.reg_rules = {
-		/* Channel 1 - 11 */
-		REG_RULE(2412-10, 2462+10, 40, 3, 20, 0),
-		/* Channel 12 - 13 */
-		REG_RULE(2467-10, 2472+10, 20, 3, 20,
-			 NL80211_RRF_NO_IR),
-		/* Channel 14 */
-		REG_RULE(2484-10, 2484+10, 20, 3, 20,
-			 NL80211_RRF_NO_IR |
-			 NL80211_RRF_NO_OFDM),
-		/* Channel 36 - 48 */
-		REG_RULE(5180-10, 5240+10, 40, 3, 20,
-			 NL80211_RRF_NO_IR),
-		/* Channel 149 - 165 */
-		REG_RULE(5745-10, 5825+10, 40, 3, 20,
-			 NL80211_RRF_NO_IR),
-		/* Channel 52 - 64 */
-		REG_RULE(5260-10, 5320+10, 40, 3, 30,
-			 NL80211_RRF_NO_IR |
-			 NL80211_RRF_DFS),
-		/* Channel 100 - 140 */
-		REG_RULE(5500-10, 5700+10, 40, 3, 30,
-			 NL80211_RRF_NO_IR |
-			 NL80211_RRF_DFS),
-	}
-};
-
 /*
  * This function maps the nl802.11 channel type into driver channel type.
  *
@@ -2916,12 +2886,6 @@ int mwifiex_register_cfg80211(struct mwifiex_adapter *adapter)
 		wiphy->flags |= WIPHY_FLAG_SUPPORTS_TDLS |
 				WIPHY_FLAG_TDLS_EXTERNAL_SETUP;
 
-	wiphy->regulatory_flags |=
-			REGULATORY_CUSTOM_REG |
-			REGULATORY_STRICT_REG;
-
-	wiphy_apply_custom_regulatory(wiphy, &mwifiex_world_regdom_custom);
