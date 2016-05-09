From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 27/36] openvswitch: __nf_ct_l{3,4}proto_find() always return a valid pointer
Date: Mon,  9 May 2016 20:46:45 +0200
Message-ID: <1462819614-5402-28-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45732 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752763AbcEISrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 14:47:31 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 32A25E8E89
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 07924FAB5A
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 5E87C134704
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:27 +0200 (CEST)
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the protocol is not natively supported, this assigns generic protocol
tracker so we can always assume a valid pointer after these calls.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Jarno Rajahalme <jrajahalme@nicira.com>
Acked-by: Joe Stringer <joe@ovn.org>
---
 net/openvswitch/conntrack.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 9741a76..9f0bc49 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -439,20 +439,12 @@ ovs_ct_find_existing(struct net *net, const struct nf_conntrack_zone *zone,
 	u8 protonum;
 
 	l3proto = __nf_ct_l3proto_find(l3num);
-	if (!l3proto) {
-		pr_debug("ovs_ct_find_existing: Can't get l3proto\n");
-		return NULL;
-	}
 	if (l3proto->get_l4proto(skb, skb_network_offset(skb), &dataoff,
 				 &protonum) <= 0) {
 		pr_debug("ovs_ct_find_existing: Can't get protonum\n");
 		return NULL;
 	}
 	l4proto = __nf_ct_l4proto_find(l3num, protonum);
-	if (!l4proto) {
-		pr_debug("ovs_ct_find_existing: Can't get l4proto\n");
-		return NULL;
-	}
 	if (!nf_ct_get_tuple(skb, skb_network_offset(skb), dataoff, l3num,
 			     protonum, net, &tuple, l3proto, l4proto)) {
 		pr_debug("ovs_ct_find_existing: Can't get tuple\n");
-- 
2.1.4
