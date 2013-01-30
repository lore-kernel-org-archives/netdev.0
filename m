From: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Subject: [PATCH] nl80211: avoid "wdev_id may be used uninitialized"
Date: Tue, 29 Jan 2013 17:11:02 -0700
Message-ID: <1359504662-23561-1-git-send-email-swarren@wwwdotorg.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stephen Warren <swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Stephen Warren <swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>

Silence the following:
net/wireless/nl80211.c: In function '__cfg80211_wdev_from_attrs.clone.119':
net/wireless/nl80211.c:57:6: warning: 'wdev_id' may be used uninitialized in this function

... by always initializing wdev_id to zero. I assume that wiphy_idx and
ifidx are set to -1 for similar reasons, so this change simply propagates
the same workaround.

In practice, this warning is false, since wdev_id is both set and used
under the condition if (have_wdev_id). However, at least my compiler
can't be coerced into realizing this; almost any code between the if
blocks that set and use the variable causes this warning.

Signed-off-by: Stephen Warren <swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
---
 net/wireless/nl80211.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 33de803..389e62a 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -54,7 +54,7 @@ __cfg80211_wdev_from_attrs(struct net *netns, struct nlattr **attrs)
 	struct wireless_dev *result = NULL;
 	bool have_ifidx = attrs[NL80211_ATTR_IFINDEX];
 	bool have_wdev_id = attrs[NL80211_ATTR_WDEV];
-	u64 wdev_id;
+	u64 wdev_id = 0;
 	int wiphy_idx = -1;
 	int ifidx = -1;
 
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
