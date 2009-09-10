From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/31: nf_conntrack: add SCTP support for SO_ORIGINAL_DST
Date: Thu, 10 Sep 2009 18:11:48 +0200 (MEST)
Message-ID: <20090910161143.31179.80177.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64620 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbZIJQLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 12:11:45 -0400
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 549812799c8495451e71ebd9f6a862b33120a35a
Author: Rafael Laufer <rlaufer@cs.ucla.edu>
Date:   Mon Aug 10 10:08:27 2009 +0200

    netfilter: nf_conntrack: add SCTP support for SO_ORIGINAL_DST
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 7d2ead7..05a9bc8 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -256,11 +256,11 @@ getorigdst(struct sock *sk, int optval, void __user *user, int *len)
 	tuple.dst.u3.ip = inet->daddr;
 	tuple.dst.u.tcp.port = inet->dport;
 	tuple.src.l3num = PF_INET;
-	tuple.dst.protonum = IPPROTO_TCP;
+	tuple.dst.protonum = sk->sk_protocol;
 
-	/* We only do TCP at the moment: is there a better way? */
-	if (strcmp(sk->sk_prot->name, "TCP")) {
-		pr_debug("SO_ORIGINAL_DST: Not a TCP socket\n");
+	/* We only do TCP and SCTP at the moment: is there a better way? */
+	if (sk->sk_protocol != IPPROTO_TCP && sk->sk_protocol != IPPROTO_SCTP) {
+		pr_debug("SO_ORIGINAL_DST: Not a TCP/SCTP socket\n");
 		return -ENOPROTOOPT;
 	}
 
