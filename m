From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: [PATCH 1/2] Interfamily IPSec BEET
Date: Mon, 4 Aug 2008 16:19:28 +0300
Message-ID: <200808041619.29180.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, yoshfuji@wide.ad.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:41593 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753126AbYHDNQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 09:16:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the ipv6-inner, ipv4-outer mode. The difference between the
two ip versions header lenghts wasn't taken into account when
re-adjusting the network header of the sk_buffs.

Signed-off-by: Joakim Koskela <jookos@gmail.com>

---
 net/ipv4/xfrm4_mode_beet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index 9c798ab..49145b0 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -48,7 +48,7 @@ static int xfrm4_beet_output(struct xfrm_state *x, struct 
sk_buff *skb)
 		hdrlen += IPV4_BEET_PHMAXLEN - (optlen & 4);
 
 	skb_set_network_header(skb, IPV4_BEET_PHMAXLEN - x->props.header_len -
-				    hdrlen);
+				    hdrlen + (XFRM_MODE_SKB_CB(skb)->ihl - sizeof(*top_iph)));
 	skb->mac_header = skb->network_header +
 			  offsetof(struct iphdr, protocol);
 	skb->transport_header = skb->network_header + sizeof(*top_iph);
