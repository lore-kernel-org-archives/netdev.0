From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 1/3] drivers/net/wireless/b43: Use local ratelimit_state
Date: Sat, 19 Jun 2010 16:30:09 -0700
Message-ID: <4b06544d432227e8587f17330f73edcaa734de86.1276988387.git.joe@perches.com>
References: <cover.1276988387.git.joe@perches.com>
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1276988387.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Avoid limiting the logging output of other networking devices

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/b43/main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 7965b70..8031f24 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -311,13 +311,15 @@ static int b43_wireless_core_start(struct b43_wldev *dev);
 
 static int b43_ratelimit(struct b43_wl *wl)
 {
+	static DEFINE_RATELIMIT_STATE(ratelimit, 5 * HZ, 10);
+
 	if (!wl || !wl->current_dev)
 		return 1;
 	if (b43_status(wl->current_dev) < B43_STAT_STARTED)
 		return 1;
 	/* We are up and running.
 	 * Ratelimit the messages to avoid DoS over the net. */
-	return net_ratelimit();
+	return __ratelimit(&ratelimit);
 }
 
 void b43info(struct b43_wl *wl, const char *fmt, ...)
-- 
1.7.1.337.g6068.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
