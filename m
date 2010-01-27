From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] ipv6: Fix possible NULL dereference in icmp6_dst_alloc
Date: Wed, 27 Jan 2010 09:59:52 +0000
Message-ID: <20100127095952.GA11635@ff.dom.local>
References: <20100123.022210.56302976.davem@davemloft.net> <20100126094817.GA7780@ff.dom.local> <20100126103524.GB7780@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, djohnson@starentnetworks.com,
	sakkiped@starentnetworks.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:38712 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752900Ab0A0KAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 05:00:00 -0500
Received: by fxm20 with SMTP id 20so1356555fxm.21
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 01:59:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100126103524.GB7780@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While looking at the "Deadlock in IPv6 code while garbage collection
on the rwlock protecting the routing tree" reported by Srinivas
Akkipeddi I found there is possible a NULL pointer dereference in
icmp6_dst_alloc().

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/ipv6/route.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c2bd74c..93c3b20 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -973,7 +973,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops);
 	if (unlikely(rt == NULL)) {
 		in6_dev_put(idev);
-		goto out;
+		return NULL;
 	}
 
 	dev_hold(dev);
@@ -1009,7 +1009,6 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 
 	fib6_force_start_gc(net);
 
-out:
 	return &rt->u.dst;
 }
 
