From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] Fix "ntohl(ntohs" bugs
Date: Thu, 18 May 2006 13:37:33 +0400
Message-ID: <20060518093733.GA15918@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:53860 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751321AbWERJjC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 May 2006 05:39:02 -0400
Received: by nf-out-0910.google.com with SMTP id o63so85242nfa
        for <netdev@vger.kernel.org>; Thu, 18 May 2006 02:39:01 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/ipcomp.c       |    2 +-
 net/ipv4/xfrm4_policy.c |    2 +-
 net/ipv6/ipcomp6.c      |    2 +-
 net/xfrm/xfrm_input.c   |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

--- a/net/ipv4/ipcomp.c
+++ 1/net/ipv4/ipcomp.c
@@ -210,7 +210,7 @@ static void ipcomp4_err(struct sk_buff *
 	    skb->h.icmph->code != ICMP_FRAG_NEEDED)
 		return;
 
-	spi = ntohl(ntohs(ipch->cpi));
+	spi = htonl(ntohs(ipch->cpi));
 	x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr,
 	                      spi, IPPROTO_COMP, AF_INET);
 	if (!x)
--- a/net/ipv4/xfrm4_policy.c
+++ 1/net/ipv4/xfrm4_policy.c
@@ -221,7 +221,7 @@ _decode_session4(struct sk_buff *skb, st
 			if (pskb_may_pull(skb, xprth + 4 - skb->data)) {
 				u16 *ipcomp_hdr = (u16 *)xprth;
 
-				fl->fl_ipsec_spi = ntohl(ntohs(ipcomp_hdr[1]));
+				fl->fl_ipsec_spi = htonl(ntohs(ipcomp_hdr[1]));
 			}
 			break;
 		default:
--- a/net/ipv6/ipcomp6.c
+++ 1/net/ipv6/ipcomp6.c
@@ -208,7 +208,7 @@ static void ipcomp6_err(struct sk_buff *
 	if (type != ICMPV6_DEST_UNREACH && type != ICMPV6_PKT_TOOBIG)
 		return;
 
-	spi = ntohl(ntohs(ipcomph->cpi));
+	spi = htonl(ntohs(ipcomph->cpi));
 	x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, spi, IPPROTO_COMP, AF_INET6);
 	if (!x)
 		return;
--- a/net/xfrm/xfrm_input.c
+++ 1/net/xfrm/xfrm_input.c
@@ -62,7 +62,7 @@ int xfrm_parse_spi(struct sk_buff *skb, 
 	case IPPROTO_COMP:
 		if (!pskb_may_pull(skb, sizeof(struct ip_comp_hdr)))
 			return -EINVAL;
-		*spi = ntohl(ntohs(*(u16*)(skb->h.raw + 2)));
+		*spi = htonl(ntohs(*(u16*)(skb->h.raw + 2)));
 		*seq = 0;
 		return 0;
 	default:

