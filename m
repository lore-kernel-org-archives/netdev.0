From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/04: ip6t_ipv6header: fix match on packets ending with NEXTHDR_NONE
Date: Tue,  5 May 2009 18:47:45 +0200 (MEST)
Message-ID: <20090505164744.19290.22694.sendpatchset@x2.localnet>
References: <20090505164742.19290.7829.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46579 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032AbZEEQrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 12:47:45 -0400
In-Reply-To: <20090505164742.19290.7829.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit b98b4947cb79d670fceca0e951c092eea93e9baa
Author: Christoph Paasch <christoph.paasch@gmail.com>
Date:   Tue May 5 15:32:16 2009 +0200

    netfilter: ip6t_ipv6header: fix match on packets ending with NEXTHDR_NONE
    
    As packets ending with NEXTHDR_NONE don't have a last extension header,
    the check for the length needs to be after the check for NEXTHDR_NONE.
    
    Signed-off-by: Christoph Paasch <christoph.paasch@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv6/netfilter/ip6t_ipv6header.c b/net/ipv6/netfilter/ip6t_ipv6header.c
index 14e6724..91490ad 100644
--- a/net/ipv6/netfilter/ip6t_ipv6header.c
+++ b/net/ipv6/netfilter/ip6t_ipv6header.c
@@ -50,14 +50,14 @@ ipv6header_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 		struct ipv6_opt_hdr _hdr;
 		int hdrlen;
 
-		/* Is there enough space for the next ext header? */
-		if (len < (int)sizeof(struct ipv6_opt_hdr))
-			return false;
 		/* No more exthdr -> evaluate */
 		if (nexthdr == NEXTHDR_NONE) {
 			temp |= MASK_NONE;
 			break;
 		}
+		/* Is there enough space for the next ext header? */
+		if (len < (int)sizeof(struct ipv6_opt_hdr))
+			return false;
 		/* ESP -> evaluate */
 		if (nexthdr == NEXTHDR_ESP) {
 			temp |= MASK_ESP;
