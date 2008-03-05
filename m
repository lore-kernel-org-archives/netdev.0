From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 8/9][NETNS][IPV6] ip6_input - enable ipv6_rcv to handle several network namespace
Date: Wed, 05 Mar 2008 18:56:57 +0100
Message-ID: <20080305180204.671149462@mai.toulouse-stg.fr.ibm.com>
References: <20080305175649.348451657@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:38590 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756AbYCESCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 13:02:12 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m25I289e192908
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:08 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m25I28RL2142396
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:08 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m25I281f019810
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:08 GMT
Content-Disposition: inline; filename=ip6-input-disable-multinetns-protection.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The different subsystem of ipv6 are ready for namespaces, so let's
activate it for ipv6_rcv.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/ip6_input.c |    5 -----
 1 file changed, 5 deletions(-)

Index: net-2.6.26/net/ipv6/ip6_input.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ip6_input.c
+++ net-2.6.26/net/ipv6/ip6_input.c
@@ -61,11 +61,6 @@ int ipv6_rcv(struct sk_buff *skb, struct
 	u32 		pkt_len;
 	struct inet6_dev *idev;
 
-	if (dev->nd_net != &init_net) {
-		kfree_skb(skb);
-		return 0;
-	}
-
 	if (skb->pkt_type == PACKET_OTHERHOST) {
 		kfree_skb(skb);
 		return 0;

-- 
