From: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
Subject: [PATCH] net, wireless: Don't return uninitialized in
 __cfg80211_stop_sched_scan()
Date: Wed, 29 Jun 2011 22:13:31 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1106292212110.3747@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If the 'driver_initiated' function argument to
__cfg80211_stop_sched_scan() is not 0 then we'll return an
uninitialized 'ret' from the function.

Signed-off-by: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
---
 net/wireless/scan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index 7a6c676..7940fa5 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -132,7 +132,7 @@ EXPORT_SYMBOL(cfg80211_sched_scan_stopped);
 int __cfg80211_stop_sched_scan(struct cfg80211_registered_device *rdev,
 			       bool driver_initiated)
 {
-	int err;
+	int err = 0;
 	struct net_device *dev;
 
 	ASSERT_RDEV_LOCK(rdev);
-- 
1.7.5.2


-- 
Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
