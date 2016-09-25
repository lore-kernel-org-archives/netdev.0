From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/53] netfilter: nf_tables_ipv6: setup pktinfo transport field on failure to parse
Date: Mon, 26 Sep 2016 01:06:26 +0200
Message-ID: <1474844823-2026-17-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54532 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034560AbcIYXHh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:07:37 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id AADE7C0B3F
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:35 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 97972DA84C
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:35 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 90B2CDA7F6
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:33 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure the pktinfo protocol fields are initialized if this fails to
parse the transport header.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables_ipv6.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_tables_ipv6.h b/include/net/netfilter/nf_tables_ipv6.h
index 6aeee47b1b5e..1e0ffd5aea47 100644
--- a/include/net/netfilter/nf_tables_ipv6.h
+++ b/include/net/netfilter/nf_tables_ipv6.h
@@ -15,9 +15,10 @@ nft_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
 	nft_set_pktinfo(pkt, skb, state);
 
 	protohdr = ipv6_find_hdr(pkt->skb, &thoff, -1, &frag_off, NULL);
-	/* If malformed, drop it */
-	if (protohdr < 0)
+	if (protohdr < 0) {
+		nft_set_pktinfo_proto_unspec(pkt, skb);
 		return -1;
+	}
 
 	pkt->tprot_set = true;
 	pkt->tprot = protohdr;
-- 
2.1.4
