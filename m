From: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>
Subject: [PATCH] net: sctp: fix initialization of local source address on
 accepted ipv6 sockets
Date: Thu, 06 Feb 2014 08:30:10 +0100
Message-ID: <52F33A02.2040902@nsn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:11380 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbaBFHa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 02:30:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 	efe4208f47f907b86f528788da711e8ab9dea44d:
'ipv6: make lookups simpler and faster' broke initialization of local source
address on accepted ipv6 sockets. Before the mentioned commit receive address
was copied along with the contents of ipv6_pinfo in sctp_v6_create_accept_sk.
Now when it is moved, it has to be copied separately.

This also fixes lksctp's ipv6 regression in a sense that test_getname_v6, TC5 -
'getsockname on a connected server socket' now passes.

Signed-off-by: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>

--- net-next.orig/net/sctp/ipv6.c
+++ net-next/net/sctp/ipv6.c
@@ -662,6 +662,8 @@ static struct sock *sctp_v6_create_accep
 	 */
 	sctp_v6_to_sk_daddr(&asoc->peer.primary_addr, newsk);
 
+	newsk->sk_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
+
 	sk_refcnt_debug_inc(newsk);
 
 	if (newsk->sk_prot->init(newsk)) {
