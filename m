From: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>
Subject: [PATCH 2.6.21-rc3] IPV6: ipv6_fl_socklist is inadvertently shared.
Date: Fri, 16 Mar 2007 10:45:42 -0700
Message-ID: <45FAD7C6.30305@ncos.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mhuth@mvista.com,
	nakagawa.msy@ncos.nec.co.jp
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:33391 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965795AbXCPRqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 13:46:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ipv6_fl_socklist from listening socket is inadvertently shared
with new socket created for connection.  This leads to a variety of
interesting, but fatal, bugs. For example, removing one of the
sockets may lead to the other socket's encountering a page fault
when the now freed list is referenced.

The fix is to not share the flow label list with the new socket.

Signed-off-by: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>

Index: linux-2.6/net/ipv6/tcp_ipv6.c
===================================================================
--- linux-2.6.orig/net/ipv6/tcp_ipv6.c
+++ linux-2.6/net/ipv6/tcp_ipv6.c
@@ -1453,6 +1453,7 @@ static struct sock * tcp_v6_syn_recv_soc
 	   First: no IPv4 options.
 	 */
 	newinet->opt = NULL;
+	newnp->ipv6_fl_list = NULL;

 	/* Clone RX bits */
 	newnp->rxopt.all = np->rxopt.all;
