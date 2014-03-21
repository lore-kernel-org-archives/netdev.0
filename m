From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] ipv4: remove ip_rt_dump from route.c
Date: Fri, 21 Mar 2014 11:33:10 +0800
Message-ID: <1395372790-11056-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:56633 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755962AbaCUDdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 23:33:12 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so1788748pdb.14
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 20:33:12 -0700 (PDT)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id ff4sm18928300pad.24.2014.03.20.20.33.09
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 20:33:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

ip_rt_dump do nothing after IPv4 route caches removal, so we can remove it.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 include/net/route.h     |    1 -
 net/ipv4/fib_frontend.c |    2 +-
 net/ipv4/route.c        |    5 -----
 3 files changed, 1 insertion(+), 7 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 9d1f423..b17cf28 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -191,7 +191,6 @@ unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
 void ip_rt_multicast_event(struct in_device *);
 int ip_rt_ioctl(struct net *, unsigned int cmd, void __user *arg);
 void ip_rt_get_source(u8 *src, struct sk_buff *skb, struct rtable *rt);
-int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb);
 
 struct in_ifaddr;
 void fib_add_ifaddr(struct in_ifaddr *);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index c7539e2..1a629f8 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -659,7 +659,7 @@ static int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 
 	if (nlmsg_len(cb->nlh) >= sizeof(struct rtmsg) &&
 	    ((struct rtmsg *) nlmsg_data(cb->nlh))->rtm_flags & RTM_F_CLONED)
-		return ip_rt_dump(skb, cb);
+		return skb->len;
 
 	s_h = cb->args[0];
 	s_e = cb->args[1];
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 11e4384..a8f2612 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2474,11 +2474,6 @@ errout_free:
 	goto errout;
 }
 
-int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb)
-{
-	return skb->len;
-}
-
 void ip_rt_multicast_event(struct in_device *in_dev)
 {
 	rt_cache_flush(dev_net(in_dev->dev));
-- 
1.7.10.4
