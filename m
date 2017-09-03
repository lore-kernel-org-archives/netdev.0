From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 35/47] netfilter: conntrack: reduce size of l4protocol trackers
Date: Mon,  4 Sep 2017 00:41:44 +0200
Message-ID: <1504478516-13224-3-git-send-email-pablo@netfilter.org>
References: <1504478516-13224-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52906 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753443AbdICWmN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:42:13 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 1369D190F63
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:41:46 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 04B292DC85
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:41:46 +0200 (CEST)
In-Reply-To: <1504478516-13224-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

can use u16 for both, shrinks size by another 8 bytes.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l4proto.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 47c16bae5e00..15c58dd3f701 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -92,12 +92,12 @@ struct nf_conntrack_l4proto {
 
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
 	struct {
-		size_t obj_size;
 		int (*nlattr_to_obj)(struct nlattr *tb[],
 				     struct net *net, void *data);
 		int (*obj_to_nlattr)(struct sk_buff *skb, const void *data);
 
-		unsigned int nlattr_max;
+		u16 obj_size;
+		u16 nlattr_max;
 		const struct nla_policy *nla_policy;
 	} ctnl_timeout;
 #endif
-- 
2.1.4
