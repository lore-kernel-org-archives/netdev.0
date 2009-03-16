From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/04: conntrack: check for NEXTHDR_NONE before header sanity checking
Date: Mon, 16 Mar 2009 17:08:47 +0100 (MET)
Message-ID: <20090316160846.3567.95967.sendpatchset@x2.localnet>
References: <20090316160841.3567.94089.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49668 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408AbZCPQIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 12:08:50 -0400
In-Reply-To: <20090316160841.3567.94089.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit d1238d5337e8e53cddea77c2a26d26b6eb5a982f
Author: Christoph Paasch <christoph.paasch@gmail.com>
Date:   Mon Mar 16 15:52:11 2009 +0100

    netfilter: conntrack: check for NEXTHDR_NONE before header sanity checking
    
    NEXTHDR_NONE doesn't has an IPv6 option header, so the first check
    for the length will always fail and results in a confusing message
    "too short" if debugging enabled. With this patch, we check for
    NEXTHDR_NONE before length sanity checkings are done.
    
    Signed-off-by: Christoph Paasch <christoph.paasch@gmail.com>
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index ed4d79a..058a5e4 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -528,14 +528,14 @@ find_prev_fhdr(struct sk_buff *skb, u8 *prevhdrp, int *prevhoff, int *fhoff)
 		if (!ipv6_ext_hdr(nexthdr)) {
 			return -1;
 		}
-		if (len < (int)sizeof(struct ipv6_opt_hdr)) {
-			pr_debug("too short\n");
-			return -1;
-		}
 		if (nexthdr == NEXTHDR_NONE) {
 			pr_debug("next header is none\n");
 			return -1;
 		}
+		if (len < (int)sizeof(struct ipv6_opt_hdr)) {
+			pr_debug("too short\n");
+			return -1;
+		}
 		if (skb_copy_bits(skb, start, &hdr, sizeof(hdr)))
 			BUG();
 		if (nexthdr == NEXTHDR_AUTH)
