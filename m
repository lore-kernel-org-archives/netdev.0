From: Yan Zheng <yanzheng@21cn.com>
Subject: [PATCH]behavior of ip6_route_input() for link local address.
Date: Thu, 20 Oct 2005 12:51:34 +0800
Message-ID: <43572256.40101@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751747AbVJTEud@vger.kernel.org>
To: netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

I find that linux will reply echo request destined to an address which belongs to an interface other than the one from which the request received.
This behavior doesn't make sense for link local address.


Index: net/ipv6/route.c
===================================================================
--- linux-2.6.14-rc4-git6/net/ipv6/route.c	2005-10-20 12:02:49.000000000 +0800
+++ linux/net/ipv6/route.c	2005-10-20 12:21:03.000000000 +0800
@@ -483,7 +483,7 @@
 		goto out;
 	}
 
-	rt = rt6_device_match(rt, skb->dev->ifindex, 0);
+	rt = rt6_device_match(rt, skb->dev->ifindex, strict);
 	BACKTRACK();
 
 	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP)) {
