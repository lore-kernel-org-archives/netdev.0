From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/29] netfilter: conntrack: Only need first 4 bytes to get l4proto ports
Date: Mon,  5 Sep 2016 12:58:16 +0200
Message-ID: <1473073124-5015-2-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35092 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932217AbcIEK65 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 06:58:57 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id A0A5E2EFEC6
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:58:55 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 913FA1150B2
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:58:55 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B08D61150C5
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:58:51 +0200 (CEST)
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

We only need first 4 bytes instead of 8 bytes to get the ports of
tcp/udp/dccp/sctp/udplite in their pkt_to_tuple function.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_dccp.c    | 3 ++-
 net/netfilter/nf_conntrack_proto_sctp.c    | 4 ++--
 net/netfilter/nf_conntrack_proto_tcp.c     | 4 ++--
 net/netfilter/nf_conntrack_proto_udp.c     | 4 ++--
 net/netfilter/nf_conntrack_proto_udplite.c | 3 ++-
 5 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 399a38f..a45bee5 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -402,7 +402,8 @@ static bool dccp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 {
 	struct dccp_hdr _hdr, *dh;
 
-	dh = skb_header_pointer(skb, dataoff, sizeof(_hdr), &_hdr);
+	/* Actually only need first 4 bytes to get ports. */
+	dh = skb_header_pointer(skb, dataoff, 4, &_hdr);
 	if (dh == NULL)
 		return false;
 
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 1d7ab96..e769f05 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -161,8 +161,8 @@ static bool sctp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 	const struct sctphdr *hp;
 	struct sctphdr _hdr;
 
-	/* Actually only need first 8 bytes. */
-	hp = skb_header_pointer(skb, dataoff, 8, &_hdr);
+	/* Actually only need first 4 bytes to get ports. */
+	hp = skb_header_pointer(skb, dataoff, 4, &_hdr);
 	if (hp == NULL)
 		return false;
 
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 70c8381..4abe9e1 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -282,8 +282,8 @@ static bool tcp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 	const struct tcphdr *hp;
 	struct tcphdr _hdr;
 
-	/* Actually only need first 8 bytes. */
-	hp = skb_header_pointer(skb, dataoff, 8, &_hdr);
+	/* Actually only need first 4 bytes to get ports. */
+	hp = skb_header_pointer(skb, dataoff, 4, &_hdr);
 	if (hp == NULL)
 		return false;
 
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 4fd0405..8a057e1 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -44,8 +44,8 @@ static bool udp_pkt_to_tuple(const struct sk_buff *skb,
 	const struct udphdr *hp;
 	struct udphdr _hdr;
 
-	/* Actually only need first 8 bytes. */
-	hp = skb_header_pointer(skb, dataoff, sizeof(_hdr), &_hdr);
+	/* Actually only need first 4 bytes to get ports. */
+	hp = skb_header_pointer(skb, dataoff, 4, &_hdr);
 	if (hp == NULL)
 		return false;
 
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 9d692f5..029206e 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -54,7 +54,8 @@ static bool udplite_pkt_to_tuple(const struct sk_buff *skb,
 	const struct udphdr *hp;
 	struct udphdr _hdr;
 
-	hp = skb_header_pointer(skb, dataoff, sizeof(_hdr), &_hdr);
+	/* Actually only need first 4 bytes to get ports. */
+	hp = skb_header_pointer(skb, dataoff, 4, &_hdr);
 	if (hp == NULL)
 		return false;
 
-- 
2.1.4
