From: Bernhard Walle <bwalle@suse.de>
Subject: [PATCH] Fix oops in xfrm4_dst_destroy()
Date: Sun, 25 Feb 2007 21:43:15 +0100
Message-ID: <20070225204315.GB31715@strauss.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Miika Komu <miika@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:36782 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751025AbXBYUnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Feb 2007 15:43:17 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With 2.6.21-rc1, I get an oops when running 'ifdown eth0' and an IPsec
connection is active. If I shut down the connection before running 'ifdown
eth0', then there's no problem.  The critical operation of this script is to
kill dhcpd.

The problem is probably caused by commit with git identifier
4337226228e1cfc1d70ee975789c6bd070fb597c (Linus tree) "[IPSEC]: IPv4 over IPv6
IPsec tunnel".

This patch fixes that oops. I don't know the network code of the Linux kernel
in deep, so if that fix is wrong, please change it. But please fix the oops. :)


Signed-off-by: Bernhard Walle <bwalle@suse.de>
---
 net/ipv4/xfrm4_policy.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.21-rc1/net/ipv4/xfrm4_policy.c
===================================================================
--- linux-2.6.21-rc1.orig/net/ipv4/xfrm4_policy.c
+++ linux-2.6.21-rc1/net/ipv4/xfrm4_policy.c
@@ -291,7 +291,7 @@ static void xfrm4_dst_destroy(struct dst
 
 	if (likely(xdst->u.rt.idev))
 		in_dev_put(xdst->u.rt.idev);
-	if (dst->xfrm->props.family == AF_INET && likely(xdst->u.rt.peer))
+	if (dst->xfrm && dst->xfrm->props.family == AF_INET && likely(xdst->u.rt.peer))
 		inet_putpeer(xdst->u.rt.peer);
 	xfrm_dst_destroy(xdst);
 }
