From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/04: nfnetlink_log: fix wrong skbuff size calculation
Date: Wed, 27 May 2009 16:35:30 +0200 (MEST)
Message-ID: <20090527143528.4649.15091.sendpatchset@x2.localnet>
References: <20090527143521.4649.73610.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51330 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760363AbZE0Of3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 10:35:29 -0400
In-Reply-To: <20090527143521.4649.73610.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit eeff9beec3d2563c42cca41e66d4169592bb5475
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Wed May 27 15:49:11 2009 +0200

    netfilter: nfnetlink_log: fix wrong skbuff size	calculation
    
    This problem was introduced in 72961ecf84d67d6359a1b30f9b2a8427f13e1e71
    since no space was reserved for the new attributes NFULA_HWTYPE,
    NFULA_HWLEN and NFULA_HWHEADER.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index fd326ac..66a6dd5 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -581,6 +581,12 @@ nfulnl_log_packet(u_int8_t pf,
 		+ nla_total_size(sizeof(struct nfulnl_msg_packet_hw))
 		+ nla_total_size(sizeof(struct nfulnl_msg_packet_timestamp));
 
+	if (in && skb_mac_header_was_set(skb)) {
+		size +=   nla_total_size(skb->dev->hard_header_len)
+			+ nla_total_size(sizeof(u_int16_t))	/* hwtype */
+			+ nla_total_size(sizeof(u_int16_t));	/* hwlen */
+	}
+
 	spin_lock_bh(&inst->lock);
 
 	if (inst->flags & NFULNL_CFG_F_SEQ)
