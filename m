From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 16/51] nf_conntrack_proto_gre: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:06 -0400
Message-ID: <1333335521-1348-17-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754196Ab2DBC72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:28 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/nf_conntrack_proto_gre.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 659648c..4bf6b4e 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -321,10 +321,11 @@ gre_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
 {
 	const unsigned int *timeouts = data;
 
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_GRE_UNREPLIED,
-			htonl(timeouts[GRE_CT_UNREPLIED] / HZ));
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_GRE_REPLIED,
-			htonl(timeouts[GRE_CT_REPLIED] / HZ));
+	if (nla_put_be32(skb, CTA_TIMEOUT_GRE_UNREPLIED,
+			 htonl(timeouts[GRE_CT_UNREPLIED] / HZ)) ||
+	    nla_put_be32(skb, CTA_TIMEOUT_GRE_REPLIED,
+			 htonl(timeouts[GRE_CT_REPLIED] / HZ)))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
-- 
1.7.7.6
