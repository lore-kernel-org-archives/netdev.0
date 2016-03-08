From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/10] netfilter: nf_defrag_ipv4: Drop redundant ip_send_check()
Date: Tue,  8 Mar 2016 11:00:45 +0100
Message-ID: <1457431250-3086-6-git-send-email-pablo@netfilter.org>
References: <1457431250-3086-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40451 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932488AbcCHKBM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2016 05:01:12 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 46CD98427
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2016 11:01:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 3A27E28D24E
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2016 11:01:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 3E8D428D240
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2016 11:01:05 +0100 (CET)
In-Reply-To: <1457431250-3086-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@ovn.org>

Since commit 0848f6428ba3 ("inet: frags: fix defragmented packet's IP
header for af_packet"), ip_send_check() would be called twice for
defragmentation that occurs from netfilter ipv4 defrag hooks. Remove the
extra call.

Signed-off-by: Joe Stringer <joe@ovn.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_defrag_ipv4.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index a04dee5..d88da36 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -31,10 +31,8 @@ static int nf_ct_ipv4_gather_frags(struct net *net, struct sk_buff *skb,
 	err = ip_defrag(net, skb, user);
 	local_bh_enable();
 
-	if (!err) {
-		ip_send_check(ip_hdr(skb));
+	if (!err)
 		skb->ignore_df = 1;
-	}
 
 	return err;
 }
-- 
2.1.4
