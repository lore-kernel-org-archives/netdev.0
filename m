From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH net-2.6.25 19/19] [NETNS] Enable routing configuration in
	non-initial namespace.
Date: Wed,  9 Jan 2008 21:04:40 +0300
Message-ID: <1199901880-6812-19-git-send-email-den@openvz.org>
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

I.e. remove the net != &init_net checks from the places, that now can handle
other-than-init net namespace.

Acked-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Acked-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 net/ipv4/fib_frontend.c |   16 ----------------
 1 files changed, 0 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index a5c47fc..a5e2fb3 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -572,9 +572,6 @@ static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *ar
 	struct fib_table *tb;
 	int err;
 
-	if (net != &init_net)
-		return -EINVAL;
-
 	err = rtm_to_fib_config(net, skb, nlh, &cfg);
 	if (err < 0)
 		goto errout;
@@ -597,9 +594,6 @@ static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *ar
 	struct fib_table *tb;
 	int err;
 
-	if (net != &init_net)
-		return -EINVAL;
-
 	err = rtm_to_fib_config(net, skb, nlh, &cfg);
 	if (err < 0)
 		goto errout;
@@ -625,9 +619,6 @@ static int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 	struct hlist_head *head;
 	int dumped = 0;
 
-	if (net != &init_net)
-		return 0;
-
 	if (nlmsg_len(cb->nlh) >= sizeof(struct rtmsg) &&
 	    ((struct rtmsg *) nlmsg_data(cb->nlh))->rtm_flags & RTM_F_CLONED)
 		return ip_rt_dump(skb, cb);
@@ -931,9 +922,6 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 	struct net_device *dev = ptr;
 	struct in_device *in_dev = __in_dev_get_rtnl(dev);
 
-	if (dev->nd_net != &init_net)
-		return NOTIFY_DONE;
-
 	if (event == NETDEV_UNREGISTER) {
 		fib_disable_ip(dev, 2);
 		return NOTIFY_DONE;
@@ -1013,10 +1001,6 @@ static int __net_init fib_net_init(struct net *net)
 {
 	int error;
 
-	error = 0;
-	if (net != &init_net)
-		goto out;
-
 	error = ip_fib_net_init(net);
 	if (error < 0)
 		goto out;
-- 
1.5.3.rc5
