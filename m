From: "Paul Moore" <paul.moore@hp.com>
Subject: [PATCH] INET: fix incorrect "inet_sock->is_icsk" assignment
Date: Thu, 04 Jan 2007 15:04:31 -0500
Message-ID: <20070104200437.008980288@hp.com>
References: <20070104200430.149943972@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:51075 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030299AbXADX4X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jan 2007 18:56:23 -0500
Received: from smtp1.fc.hp.com (smtp1.fc.hp.com [15.15.136.127])
	by atlrel7.hp.com (Postfix) with ESMTP id 6076134407
	for <netdev@vger.kernel.org>; Thu,  4 Jan 2007 18:56:22 -0500 (EST)
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=network-fix_icsk_assignment
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

The inet_create() and inet6_create() functions incorrectly set the
inet_sock->is_icsk field.  Both functions assume that the is_icsk field is
large enough to hold at least a INET_PROTOSW_ICSK value when it is actually
only a single bit.  This patch corrects the assignment by doing a boolean
comparison whose result will safely fit into a single bit field.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/ipv4/af_inet.c  |    2 +-
 net/ipv6/af_inet6.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

Index: net-2.6.20_bugfix_2/net/ipv4/af_inet.c
===================================================================
--- net-2.6.20_bugfix_2.orig/net/ipv4/af_inet.c
+++ net-2.6.20_bugfix_2/net/ipv4/af_inet.c
@@ -305,7 +305,7 @@ lookup_protocol:
 		sk->sk_reuse = 1;
 
 	inet = inet_sk(sk);
-	inet->is_icsk = INET_PROTOSW_ICSK & answer_flags;
+	inet->is_icsk = (INET_PROTOSW_ICSK & answer_flags) == INET_PROTOSW_ICSK;
 
 	if (SOCK_RAW == sock->type) {
 		inet->num = protocol;
Index: net-2.6.20_bugfix_2/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.20_bugfix_2.orig/net/ipv6/af_inet6.c
+++ net-2.6.20_bugfix_2/net/ipv6/af_inet6.c
@@ -171,7 +171,7 @@ lookup_protocol:
 		sk->sk_reuse = 1;
 
 	inet = inet_sk(sk);
-	inet->is_icsk = INET_PROTOSW_ICSK & answer_flags;
+	inet->is_icsk = (INET_PROTOSW_ICSK & answer_flags) == INET_PROTOSW_ICSK;
 
 	if (SOCK_RAW == sock->type) {
 		inet->num = protocol;

--
paul moore
linux security @ hp

