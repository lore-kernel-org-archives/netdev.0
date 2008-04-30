From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [net-2.6 patch 2/2][NETNS] Fix reassembly timer to use the right namespace
Date: Wed, 30 Apr 2008 23:31:15 +0200
Message-ID: <20080430213322.234776390@localhost.localdomain>
References: <20080430213113.410541118@localhost.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:46282 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759419AbYD3Vdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 17:33:43 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m3ULXgOn107772
	for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 21:33:42 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3ULXgWh4337898
	for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 23:33:42 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3ULXfSG015493
	for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 23:33:41 +0200
Content-Disposition: inline; filename=fix-reassembly-timer.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This trivial fix retrieves the network namespace from frag queue
and use it to get the network device in the right namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/reassembly.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: net-2.6/net/ipv6/reassembly.c
===================================================================
--- net-2.6.orig/net/ipv6/reassembly.c
+++ net-2.6/net/ipv6/reassembly.c
@@ -197,6 +197,7 @@ static void ip6_frag_expire(unsigned lon
 {
 	struct frag_queue *fq;
 	struct net_device *dev = NULL;
+	struct net *net;
 
 	fq = container_of((struct inet_frag_queue *)data, struct frag_queue, q);
 
@@ -207,7 +208,8 @@ static void ip6_frag_expire(unsigned lon
 
 	fq_kill(fq);
 
-	dev = dev_get_by_index(&init_net, fq->iif);
+	net = container_of(fq->q.net, struct net, ipv6.frags);
+	dev = dev_get_by_index(net, fq->iif);
 	if (!dev)
 		goto out;
 

-- 
