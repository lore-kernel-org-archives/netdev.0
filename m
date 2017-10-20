From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: wireless: mark expected switch fall-throughs
Date: Fri, 20 Oct 2017 12:21:45 -0500
Message-ID: <20171020172145.GA5366@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Johannes Berg <johannes@sipsolutions.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).
Please, verify if the actual intention of the code is to fall through.

 net/wireless/chan.c        |  2 ++
 net/wireless/nl80211.c     | 10 ++++++++++
 net/wireless/scan.c        |  3 ++-
 net/wireless/wext-compat.c |  2 ++
 4 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/net/wireless/chan.c b/net/wireless/chan.c
index eb82427..6072613 100644
--- a/net/wireless/chan.c
+++ b/net/wireless/chan.c
@@ -741,6 +741,7 @@ bool cfg80211_chandef_usable(struct wiphy *wiphy,
 	case NL80211_CHAN_WIDTH_20:
 		if (!ht_cap->ht_supported)
 			return false;
+		/* fall through */
 	case NL80211_CHAN_WIDTH_20_NOHT:
 		prohibited_flags |= IEEE80211_CHAN_NO_20MHZ;
 		width = 20;
@@ -763,6 +764,7 @@ bool cfg80211_chandef_usable(struct wiphy *wiphy,
 		cap = vht_cap->cap & IEEE80211_VHT_CAP_SUPP_CHAN_WIDTH_MASK;
 		if (cap != IEEE80211_VHT_CAP_SUPP_CHAN_WIDTH_160_80PLUS80MHZ)
 			return false;
+		/* fall through */
 	case NL80211_CHAN_WIDTH_80:
 		if (!vht_cap->vht_supported)
 			return false;
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index fce2cbe..a8bbb6c 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -1509,6 +1509,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 		state->split_start++;
 		if (state->split)
 			break;
+		/* fall through */
 	case 1:
 		if (nla_put(msg, NL80211_ATTR_CIPHER_SUITES,
 			    sizeof(u32) * rdev->wiphy.n_cipher_suites,
@@ -1555,6 +1556,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 		state->split_start++;
 		if (state->split)
 			break;
+		/* fall through */
 	case 2:
 		if (nl80211_put_iftypes(msg, NL80211_ATTR_SUPPORTED_IFTYPES,
 					rdev->wiphy.interface_modes))
@@ -1562,6 +1564,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 		state->split_start++;
 		if (state->split)
 			break;
+		/* fall through */
 	case 3:
 		nl_bands = nla_nest_start(msg, NL80211_ATTR_WIPHY_BANDS);
 		if (!nl_bands)
@@ -1587,6 +1590,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 				state->chan_start++;
 				if (state->split)
 					break;
+				/* fall through */
 			default:
 				/* add frequencies */
 				nl_freqs = nla_nest_start(
@@ -1640,6 +1644,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 			state->split_start++;
 		if (state->split)
 			break;
+		/* fall through */
 	case 4:
 		nl_cmds = nla_nest_start(msg, NL80211_ATTR_SUPPORTED_COMMANDS);
 		if (!nl_cmds)
@@ -1666,6 +1671,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 		state->split_start++;
 		if (state->split)
 			break;
+		/* fall through */
 	case 5:
 		if (rdev->ops->remain_on_channel &&
 		    (rdev->wiphy.flags & WIPHY_FLAG_HAS_REMAIN_ON_CHANNEL) &&
@@ -1683,6 +1689,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 		state->split_start++;
 		if (state->split)
 			break;
+		/* fall through */
 	case 6:
 #ifdef CONFIG_PM
 		if (nl80211_send_wowlan(msg, rdev, state->split))
@@ -1693,6 +1700,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 #else
 		state->split_start++;
 #endif
+		/* fall through */
 	case 7:
 		if (nl80211_put_iftypes(msg, NL80211_ATTR_SOFTWARE_IFTYPES,
 					rdev->wiphy.software_iftypes))
@@ -1705,6 +1713,7 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
 		state->split_start++;
 		if (state->split)
 			break;
+		/* fall through */
 	case 8:
 		if ((rdev->wiphy.flags & WIPHY_FLAG_HAVE_AP_SME) &&
 		    nla_put_u32(msg, NL80211_ATTR_DEVICE_AP_SME,
@@ -4192,6 +4201,7 @@ static int parse_station_flags(struct genl_info *info,
 		params->sta_flags_mask = BIT(NL80211_STA_FLAG_AUTHENTICATED) |
 					 BIT(NL80211_STA_FLAG_MFP) |
 					 BIT(NL80211_STA_FLAG_AUTHORIZED);
+		/* fall through */
 	default:
 		return -EINVAL;
 	}
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index 9f0901f..ebfb6d8 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -1139,7 +1139,8 @@ cfg80211_inform_bss_data(struct wiphy *wiphy,
 	switch (ftype) {
 	case CFG80211_BSS_FTYPE_BEACON:
 		ies->from_beacon = true;
-		/* fall through to assign */
+		/* to assign */
+		/* fall through */
 	case CFG80211_BSS_FTYPE_UNKNOWN:
 		rcu_assign_pointer(tmp.pub.beacon_ies, ies);
 		break;
diff --git a/net/wireless/wext-compat.c b/net/wireless/wext-compat.c
index 5d4a02c..a8d96e7 100644
--- a/net/wireless/wext-compat.c
+++ b/net/wireless/wext-compat.c
@@ -1333,6 +1333,7 @@ static struct iw_statistics *cfg80211_wireless_stats(struct net_device *dev)
 			wstats.qual.qual = sig + 110;
 			break;
 		}
+		/* fall through */
 	case CFG80211_SIGNAL_TYPE_UNSPEC:
 		if (sinfo.filled & BIT(NL80211_STA_INFO_SIGNAL)) {
 			wstats.qual.updated |= IW_QUAL_LEVEL_UPDATED;
@@ -1341,6 +1342,7 @@ static struct iw_statistics *cfg80211_wireless_stats(struct net_device *dev)
 			wstats.qual.qual = sinfo.signal;
 			break;
 		}
+		/* fall through */
 	default:
 		wstats.qual.updated |= IW_QUAL_LEVEL_INVALID;
 		wstats.qual.updated |= IW_QUAL_QUAL_INVALID;
-- 
2.7.4
