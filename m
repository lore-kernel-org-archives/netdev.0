From: Thomas Graf <tgraf@infradead.org>
Subject: [PATCH] ipv6: add special mode forwarding=2 to send RS while
 configured as router
Date: Fri, 3 Sep 2010 09:04:20 -0400
Message-ID: <20100903130420.GB28460@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@vger.kernel.org, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:55977 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325Ab0ICNEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 09:04:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to accepting router advertisement, the IPv6 stack does not send router
solicitations if forwarding is enabled.

This patch enables this behavior to be overruled by setting forwarding to the
special value 2.

Signed-off-by: Thomas Graf <tgraf@infradead.org>

Index: net-2.6/net/ipv6/addrconf.c
===================================================================
--- net-2.6.orig/net/ipv6/addrconf.c
+++ net-2.6/net/ipv6/addrconf.c
@@ -2964,7 +2964,8 @@ static void addrconf_dad_completed(struc
 	   start sending router solicitations.
 	 */
 
-	if (ifp->idev->cnf.forwarding == 0 &&
+	if ((ifp->idev->cnf.forwarding == 0 ||
+	     ifp->idev->cnf.forwarding == 2) &&
 	    ifp->idev->cnf.rtr_solicits > 0 &&
 	    (dev->flags&IFF_LOOPBACK) == 0 &&
 	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
