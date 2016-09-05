From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 28/29] netfilter: log_arp: Use ARPHRD_ETHER instead of literal '1'
Date: Mon,  5 Sep 2016 12:58:43 +0200
Message-ID: <1473073124-5015-29-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35196 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933461AbcIEK7U (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 06:59:20 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id BA2282EFED1
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:19 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id AACDE1153F4
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:19 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 88B3F10219F
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:17 +0200 (CEST)
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

There is one macro ARPHRD_ETHER which defines the ethernet proto for ARP,
so we could use it instead of the literal number '1'.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_log_arp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/netfilter/nf_log_arp.c b/net/ipv4/netfilter/nf_log_arp.c
index e7ad950..cf8f2d4 100644
--- a/net/ipv4/netfilter/nf_log_arp.c
+++ b/net/ipv4/netfilter/nf_log_arp.c
@@ -62,7 +62,7 @@ static void dump_arp_packet(struct nf_log_buf *m,
 	/* If it's for Ethernet and the lengths are OK, then log the ARP
 	 * payload.
 	 */
-	if (ah->ar_hrd != htons(1) ||
+	if (ah->ar_hrd != htons(ARPHRD_ETHER) ||
 	    ah->ar_hln != ETH_ALEN ||
 	    ah->ar_pln != sizeof(__be32))
 		return;
-- 
2.1.4
