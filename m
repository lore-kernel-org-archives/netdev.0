From: kaber@trash.net
Subject: [PATCH 05/17] netfilter: nf_nat: remove obsolete check in nf_nat_mangle_udp_packet()
Date: Mon, 21 Nov 2011 06:45:57 +0100
Message-ID: <1321854369-3432-6-git-send-email-kaber@trash.net>
References: <1321854369-3432-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61107 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324Ab1KUFrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 00:47:45 -0500
In-Reply-To: <1321854369-3432-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

The packet size check originates from a time when UDP helpers could
accidentally mangle incorrect packets (NEWNAT) and is unnecessary
nowadays since the conntrack helpers invoke the NAT helpers for the
proper packet directly.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/nf_nat_helper.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index 049e8b7..af65958 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -253,12 +253,6 @@ nf_nat_mangle_udp_packet(struct sk_buff *skb,
 	struct udphdr *udph;
 	int datalen, oldlen;
 
-	/* UDP helpers might accidentally mangle the wrong packet */
-	iph = ip_hdr(skb);
-	if (skb->len < iph->ihl*4 + sizeof(*udph) +
-			       match_offset + match_len)
-		return 0;
-
 	if (!skb_make_writable(skb, skb->len))
 		return 0;
 
-- 
1.7.1
