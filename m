From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 39/62: ctnetlink: dump expectation helper name
Date: Tue, 16 Feb 2010 15:56:13 +0100 (MET)
Message-ID: <20100216145610.2796.46932.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52058 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932667Ab0BPO4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:56:14 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit d1e7a03f4fee4059ee3fa7ce0edb7c48c1a75fcf
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Feb 11 12:22:28 2010 +0100

    netfilter: ctnetlink: dump expectation helper name
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 5c103b8..db35eda 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1512,6 +1512,7 @@ ctnetlink_exp_dump_expect(struct sk_buff *skb,
 			  const struct nf_conntrack_expect *exp)
 {
 	struct nf_conn *master = exp->master;
+	struct nf_conntrack_helper *helper;
 	long timeout = (exp->timeout.expires - jiffies) / HZ;
 
 	if (timeout < 0)
@@ -1528,6 +1529,9 @@ ctnetlink_exp_dump_expect(struct sk_buff *skb,
 
 	NLA_PUT_BE32(skb, CTA_EXPECT_TIMEOUT, htonl(timeout));
 	NLA_PUT_BE32(skb, CTA_EXPECT_ID, htonl((unsigned long)exp));
+	helper = rcu_dereference(nfct_help(master)->helper);
+	if (helper)
+		NLA_PUT_STRING(skb, CTA_EXPECT_HELP_NAME, helper->name);
 
 	return 0;
 
