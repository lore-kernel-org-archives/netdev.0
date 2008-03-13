From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [net-2.6.26 patch 3/6][NETNS][IPV6] tcp - assign the netns for timewait sockets
Date: Thu, 13 Mar 2008 12:46:12 +0100
Message-ID: <20080313114926.912248349@mai.toulouse-stg.fr.ibm.com>
References: <20080313114609.176640638@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net, den@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:57814 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417AbYCMLvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 07:51:22 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id m2DBpK4D165974
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 11:51:20 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2DBpKN51577208
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 12:51:20 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2DBpJlE010710
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 12:51:20 +0100
Content-Disposition: inline; filename=tw-copy-network-namespace-from-sock.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Copy the network namespace from the socket to the timewait
socket.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv4/inet_timewait_sock.c |    1 +
 1 file changed, 1 insertion(+)

Index: net-2.6.26/net/ipv4/inet_timewait_sock.c
===================================================================
--- net-2.6.26.orig/net/ipv4/inet_timewait_sock.c
+++ net-2.6.26/net/ipv4/inet_timewait_sock.c
@@ -124,6 +124,7 @@ struct inet_timewait_sock *inet_twsk_all
 		tw->tw_hash	    = sk->sk_hash;
 		tw->tw_ipv6only	    = 0;
 		tw->tw_prot	    = sk->sk_prot_creator;
+		tw->tw_net          = sk->sk_net;
 		atomic_set(&tw->tw_refcnt, 1);
 		inet_twsk_dead_node_init(tw);
 		__module_get(tw->tw_prot->owner);

-- 
