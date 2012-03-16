From: roy.qing.li@gmail.com
Subject: [PATCH] ipv6: Don't dev_hold(dev) in ip6_mc_find_dev_rcu.
Date: Fri, 16 Mar 2012 16:54:14 +0800
Message-ID: <1331888054-21072-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51153 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422635Ab2CPIxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 04:53:52 -0400
Received: by eekc41 with SMTP id c41so1993621eek.19
        for <netdev@vger.kernel.org>; Fri, 16 Mar 2012 01:53:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

ip6_mc_find_dev_rcu() is called with rcu_read_lock(), so don't
need to dev_hold().
With dev_hold(), not corresponding dev_put(), will lead to leak.

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 net/ipv6/mcast.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index b853f06..16c33e3 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -257,7 +257,6 @@ static struct inet6_dev *ip6_mc_find_dev_rcu(struct net *net,
 
 		if (rt) {
 			dev = rt->dst.dev;
-			dev_hold(dev);
 			dst_release(&rt->dst);
 		}
 	} else
-- 
1.7.1
