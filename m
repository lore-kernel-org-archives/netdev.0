From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 13/51] nf_conntrack_proto_udp{,lite}: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:03 -0400
Message-ID: <1333335521-1348-14-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753994Ab2DBC7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:24 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/nf_conntrack_proto_udp.c     |    9 +++++----
 net/netfilter/nf_conntrack_proto_udplite.c |    9 +++++----
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index a9073dc..7259a6b 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -181,10 +181,11 @@ udp_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
 {
 	const unsigned int *timeouts = data;
 
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_UDP_UNREPLIED,
-			htonl(timeouts[UDP_CT_UNREPLIED] / HZ));
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_UDP_REPLIED,
-			htonl(timeouts[UDP_CT_REPLIED] / HZ));
+	if (nla_put_be32(skb, CTA_TIMEOUT_UDP_UNREPLIED,
+			 htonl(timeouts[UDP_CT_UNREPLIED] / HZ)) ||
+	    nla_put_be32(skb, CTA_TIMEOUT_UDP_REPLIED,
+			 htonl(timeouts[UDP_CT_REPLIED] / HZ)))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index e060639..4d60a53 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -185,10 +185,11 @@ udplite_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
 {
 	const unsigned int *timeouts = data;
 
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_UDPLITE_UNREPLIED,
-			htonl(timeouts[UDPLITE_CT_UNREPLIED] / HZ));
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_UDPLITE_REPLIED,
-			htonl(timeouts[UDPLITE_CT_REPLIED] / HZ));
+	if (nla_put_be32(skb, CTA_TIMEOUT_UDPLITE_UNREPLIED,
+			 htonl(timeouts[UDPLITE_CT_UNREPLIED] / HZ)) ||
+	    nla_put_be32(skb, CTA_TIMEOUT_UDPLITE_REPLIED,
+			 htonl(timeouts[UDPLITE_CT_REPLIED] / HZ)))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
-- 
1.7.7.6
