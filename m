From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/5] net: add gro_compute_pseudo functions
Date: Fri, 20 Jun 2014 16:37:42 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406201631070.11970@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:34945 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753846AbaFTXho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 19:37:44 -0400
Received: by mail-oa0-f73.google.com with SMTP id eb12so1106575oac.2
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 16:37:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add inet_gro_compute_pseudo and ip6_gro_compute_pseudo. These are
the logical equivalents of inet_compute_pseudo and ip6_compute_pseudo
for GRO path. The IP header is taken from skb_gro_network_header.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip.h           | 8 ++++++++
 include/net/ip6_checksum.h | 8 ++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/net/ip.h b/include/net/ip.h
index 0e795df..d70b6c2 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -353,6 +353,14 @@ static inline __wsum inet_compute_pseudo(struct sk_buff *skb, int proto)
 				  skb->len, proto, 0);
 }
 
+static inline __wsum inet_gro_compute_pseudo(struct sk_buff *skb, int proto)
+{
+	const struct iphdr *iph = skb_gro_network_header(skb);
+
+	return csum_tcpudp_nofold(iph->saddr, iph->daddr,
+				  skb_gro_len(skb), proto, 0);
+}
+
 /*
  *	Map a multicast IP onto multicast MAC for type ethernet.
  */
diff --git a/include/net/ip6_checksum.h b/include/net/ip6_checksum.h
index 55236cb..1a49b73 100644
--- a/include/net/ip6_checksum.h
+++ b/include/net/ip6_checksum.h
@@ -48,6 +48,14 @@ static inline __wsum ip6_compute_pseudo(struct sk_buff *skb, int proto)
 					    skb->len, proto, 0));
 }
 
+static inline __wsum ip6_gro_compute_pseudo(struct sk_buff *skb, int proto)
+{
+	const struct ipv6hdr *iph = skb_gro_network_header(skb);
+
+	return ~csum_unfold(csum_ipv6_magic(&iph->saddr, &iph->daddr,
+					    skb_gro_len(skb), proto, 0));
+}
+
 static __inline__ __sum16 tcp_v6_check(int len,
 				   const struct in6_addr *saddr,
 				   const struct in6_addr *daddr,
-- 
2.0.0.526.g5318336
