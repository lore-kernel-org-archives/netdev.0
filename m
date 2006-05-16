From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ipv6: endian fix
Date: Tue, 16 May 2006 22:36:46 +0400
Message-ID: <20060516183645.GK10143@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:60484 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1750813AbWEPSiI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 14:38:08 -0400
Received: by nf-out-0910.google.com with SMTP id d4so30145nfe
        for <netdev@vger.kernel.org>; Tue, 16 May 2006 11:38:06 -0700 (PDT)
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

--- a/net/ipv6/netfilter/ip6t_eui64.c
+++ b/net/ipv6/netfilter/ip6t_eui64.c
@@ -38,11 +38,11 @@ match(const struct sk_buff *skb,
 		return 0;
 	}
 
 	memset(eui64, 0, sizeof(eui64));
 
-	if (eth_hdr(skb)->h_proto == ntohs(ETH_P_IPV6)) {
+	if (eth_hdr(skb)->h_proto == htons(ETH_P_IPV6)) {
 		if (skb->nh.ipv6h->version == 0x6) {
 			memcpy(eui64, eth_hdr(skb)->h_source, 3);
 			memcpy(eui64 + 5, eth_hdr(skb)->h_source + 3, 3);
 			eui64[3] = 0xff;
 			eui64[4] = 0xfe;

