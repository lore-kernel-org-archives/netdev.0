From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 1/3] wireless: wext: remove ndo_do_ioctl fallback
Date: Wed, 14 Jun 2017 13:55:21 +0200
Message-ID: <20170614115523.16379-2-johannes@sipsolutions.net>
References: <20170614115523.16379-1-johannes@sipsolutions.net>
Cc: Robert O'Callahan <robert@ocallahan.org>,
        Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:37324 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751843AbdFNLz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 07:55:28 -0400
In-Reply-To: <20170614115523.16379-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

There are no longer any drivers (in the tree proper, I didn't
check all the staging drivers) that take WEXT ioctls through
this API, the only remaining ones that even have ndo_do_ioctl
are using it only for private ioctls.

Therefore, we can remove this call.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/wireless/wext-core.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/wireless/wext-core.c b/net/wireless/wext-core.c
index 1a4db6790e20..24ba8a99b946 100644
--- a/net/wireless/wext-core.c
+++ b/net/wireless/wext-core.c
@@ -957,9 +957,6 @@ static int wireless_process_ioctl(struct net *net, struct ifreq *ifr,
 		else if (private)
 			return private(dev, iwr, cmd, info, handler);
 	}
-	/* Old driver API : call driver ioctl handler */
-	if (dev->netdev_ops->ndo_do_ioctl)
-		return dev->netdev_ops->ndo_do_ioctl(dev, ifr, cmd);
 	return -EOPNOTSUPP;
 }
 
-- 
2.11.0
