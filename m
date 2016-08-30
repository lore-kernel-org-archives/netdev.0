From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/7] netfilter: nf_tables_netdev: remove redundant ip_hdr assignment
Date: Tue, 30 Aug 2016 13:26:23 +0200
Message-ID: <1472556383-6787-8-git-send-email-pablo@netfilter.org>
References: <1472556383-6787-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42866 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758321AbcH3L04 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 07:26:56 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 780D21324E4
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 13:26:49 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5B146A827A
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 13:26:49 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5AA1B10219F
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 13:26:47 +0200 (CEST)
In-Reply-To: <1472556383-6787-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

We have already use skb_header_pointer to get the ip header pointer,
so there's no need to use ip_hdr again. Moreover, in NETDEV INGRESS
hook, ip header maybe not linear, so use ip_hdr is not appropriate,
remove it.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_netdev.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/nf_tables_netdev.c b/net/netfilter/nf_tables_netdev.c
index 5eefe4a..75d696f 100644
--- a/net/netfilter/nf_tables_netdev.c
+++ b/net/netfilter/nf_tables_netdev.c
@@ -30,7 +30,6 @@ nft_netdev_set_pktinfo_ipv4(struct nft_pktinfo *pkt,
 	if (!iph)
 		return;
 
-	iph = ip_hdr(skb);
 	if (iph->ihl < 5 || iph->version != 4)
 		return;
 
-- 
2.1.4
