From: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [patch] cfg80211: off by one in nl80211_trigger_scan()
Date: Fri, 29 Jul 2011 11:52:18 +0300
Message-ID: <20110729085217.GG3752@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"open list:CFG80211 and NL80211" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:NETWORKING [GENERAL]" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The test is off by one so we'd read past the end of the
wiphy->bands[] array on the next line.

Signed-off-by: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 28d2aa1..e83e7fe 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -3464,7 +3464,7 @@ static int nl80211_trigger_scan(struct sk_buff *skb, struct genl_info *info)
 				    tmp) {
 			enum ieee80211_band band = nla_type(attr);
 
-			if (band < 0 || band > IEEE80211_NUM_BANDS) {
+			if (band < 0 || band >= IEEE80211_NUM_BANDS) {
 				err = -EINVAL;
 				goto out_free;
 			}
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
