From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH net-2.6.25 18/19] [NETNS] Replace init_net with the correct
	context in fib_frontend.c
Date: Wed,  9 Jan 2008 21:04:39 +0300
Message-ID: <1199901880-6812-18-git-send-email-den@openvz.org>
References: <47850C57.60907@openvz.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org,
        benjamin.thery-6ktuUTfB/bM@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47850C57.60907-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Acked-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Acked-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 net/ipv4/fib_frontend.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index a5c47fc..a5e2fb3 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -597,7 +594,7 @@ static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *ar
 	if (err < 0)
 		goto errout;
 
-	tb = fib_new_table(&init_net, cfg.fc_table);
+	tb = fib_new_table(net, cfg.fc_table);
 	if (tb == NULL) {
 		err = -ENOBUFS;
 		goto errout;
@@ -794,7 +785,7 @@ static void fib_del_ifaddr(struct in_ifaddr *ifa)
 		fib_magic(RTM_DELROUTE, RTN_LOCAL, ifa->ifa_local, 32, prim);
 
 		/* Check, that this local address finally disappeared. */
-		if (inet_addr_type(&init_net, ifa->ifa_local) != RTN_LOCAL) {
+		if (inet_addr_type(dev->nd_net, ifa->ifa_local) != RTN_LOCAL) {
 			/* And the last, but not the least thing.
 			   We must flush stray FIB entries.
 
@@ -802,7 +793,7 @@ static void fib_del_ifaddr(struct in_ifaddr *ifa)
 			   for stray nexthop entries, then ignite fib_flush.
 			*/
 			if (fib_sync_down(ifa->ifa_local, NULL, 0))
-				fib_flush(&init_net);
+				fib_flush(dev->nd_net);
 		}
 	}
 #undef LOCAL_OK
@@ -894,7 +885,7 @@ static void nl_fib_lookup_exit(struct net *net)
 static void fib_disable_ip(struct net_device *dev, int force)
 {
 	if (fib_sync_down(0, dev, force))
-		fib_flush(&init_net);
+		fib_flush(dev->nd_net);
 	rt_cache_flush(0);
 	arp_ifdown(dev);
 }
-- 
1.5.3.rc5
