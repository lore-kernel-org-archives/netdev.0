From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next v2 3/5] ipv6: sr: enforce IPv6 packets for seg6local lwt
Date: Fri, 25 Aug 2017 09:56:46 +0200
Message-ID: <20170825075648.5061-4-david.lebrun@uclouvain.be>
References: <20170825075648.5061-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:35830 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754667AbdHYH4Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 03:56:24 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp1.sgsi.ucl.ac.be (Postfix) with ESMTPS id ED69867DED5
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 09:56:13 +0200 (CEST)
In-Reply-To: <20170825075648.5061-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ensures that the seg6local lightweight tunnel is used solely
with IPv6 routes and processes only IPv6 packets.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/seg6_local.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/ipv6/seg6_local.c b/net/ipv6/seg6_local.c
index 609b94e..c626325 100644
--- a/net/ipv6/seg6_local.c
+++ b/net/ipv6/seg6_local.c
@@ -357,6 +357,11 @@ static int seg6_local_input(struct sk_buff *skb)
 	struct seg6_action_desc *desc;
 	struct seg6_local_lwt *slwt;
 
+	if (skb->protocol != htons(ETH_P_IPV6)) {
+		kfree_skb(skb);
+		return -EINVAL;
+	}
+
 	slwt = seg6_local_lwtunnel(orig_dst->lwtstate);
 	desc = slwt->desc;
 
@@ -623,6 +628,9 @@ static int seg6_local_build_state(struct nlattr *nla, unsigned int family,
 	struct seg6_local_lwt *slwt;
 	int err;
 
+	if (family != AF_INET6)
+		return -EINVAL;
+
 	err = nla_parse_nested(tb, SEG6_LOCAL_MAX, nla, seg6_local_policy,
 			       extack);
 
-- 
2.10.2
