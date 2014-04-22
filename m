From: "Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
Subject: [PATCH] 6lowpan: nuke net_ieee802154_lowpan() accessor when 6lowpan is disabled
Date: Tue, 22 Apr 2014 12:03:58 -0700
Message-ID: <1398193438-23805-1-git-send-email-mcgrof@do-not-panic.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	backports-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Luis R. Rodriguez" <mcgrof-IBi9RG/b67k@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <backports-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: backports-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof-IBi9RG/b67k@public.gmane.org>

Johannes noted this is not needed, all of the fragment
accessors don't need CONFIG_NET_NS. This goes test compiled with
CONFIG_BT_6LOWPAN=y and a disabled CONFIG_NET_NS.

CC: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Cc: David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Signed-off-by: Luis R. Rodriguez <mcgrof-IBi9RG/b67k@public.gmane.org>
---
 include/net/net_namespace.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 066cf60..ea3cede 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -386,15 +386,8 @@ net_ieee802154_lowpan(struct net *net)
 {
 	return &net->ieee802154_lowpan;
 }
-#else
-static inline struct netns_ieee802154_lowpan *
-net_ieee802154_lowpan(struct net *net)
-{
-	return NULL;
-}
 #endif
 
-
 /* For callers who don't really care about whether it's IPv4 or IPv6 */
 static inline void rt_genid_bump_all(struct net *net)
 {
-- 
1.9.0
