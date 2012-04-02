From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 20/51] nf_conntrack_core: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:10 -0400
Message-ID: <1333335521-1348-21-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46712 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754070Ab2DBC7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:37 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/nf_conntrack_core.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index cbdb754..b0ab8c4 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1151,8 +1151,9 @@ static struct nf_ct_ext_type nf_ct_zone_extend __read_mostly = {
 int nf_ct_port_tuple_to_nlattr(struct sk_buff *skb,
 			       const struct nf_conntrack_tuple *tuple)
 {
-	NLA_PUT_BE16(skb, CTA_PROTO_SRC_PORT, tuple->src.u.tcp.port);
-	NLA_PUT_BE16(skb, CTA_PROTO_DST_PORT, tuple->dst.u.tcp.port);
+	if (nla_put_be16(skb, CTA_PROTO_SRC_PORT, tuple->src.u.tcp.port) ||
+	    nla_put_be16(skb, CTA_PROTO_DST_PORT, tuple->dst.u.tcp.port))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
-- 
1.7.7.6
