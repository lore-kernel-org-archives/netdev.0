From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 17/51] nf_conntrack_proto_generic: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:07 -0400
Message-ID: <1333335521-1348-18-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46703 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754070Ab2DBC7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:33 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/nf_conntrack_proto_generic.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index 835e24c..d8923d5 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -90,7 +90,8 @@ generic_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
 {
 	const unsigned int *timeout = data;
 
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_GENERIC_TIMEOUT, htonl(*timeout / HZ));
+	if (nla_put_be32(skb, CTA_TIMEOUT_GENERIC_TIMEOUT, htonl(*timeout / HZ)))
+		goto nla_put_failure;
 
 	return 0;
 
-- 
1.7.7.6
