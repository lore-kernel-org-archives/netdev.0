From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] ipv6 netns: init net is used to set bindv6only for new sock
Date: Thu, 05 Jun 2008 14:37:30 +0400
Message-ID: <4847C1EA.6060609@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47847 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752439AbYFEKj4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 06:39:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bindv6only is tuned via sysctl. It is already on a struct net
and per-net sysctls allow for its modification (ipv6_sysctl_net_init).

Despite this the value configured in the init net is used for the
rest of them.

Fits both net-2.6 and net-next-26

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 3c6aafb..e84b3fd 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -191,7 +191,7 @@ lookup_protocol:
 	np->mcast_hops	= -1;
 	np->mc_loop	= 1;
 	np->pmtudisc	= IPV6_PMTUDISC_WANT;
-	np->ipv6only	= init_net.ipv6.sysctl.bindv6only;
+	np->ipv6only	= net->ipv6.sysctl.bindv6only;
 
 	/* Init the ipv4 part of the socket since we can have sockets
 	 * using v6 API for ipv4.
