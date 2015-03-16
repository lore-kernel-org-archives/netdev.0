From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/3] xfrm6: Fix a offset value for network header in _decode_session6
Date: Mon, 16 Mar 2015 07:52:22 +0100
Message-ID: <1426488744-17104-2-git-send-email-steffen.klassert@secunet.com>
References: <1426488744-17104-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57369 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751472AbbCPGxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2015 02:53:06 -0400
In-Reply-To: <1426488744-17104-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hajime Tazaki <tazaki@sfc.wide.ad.jp>

When a network-layer header has multiple IPv6 extension headers, then offset
for mobility header goes wrong. This regression breaks an xfrm policy lookup
for a particular receive packet. Binding update packets of Mobile IPv6
are all discarded without this fix.

Fixes: de3b7a06dfe1 ("xfrm6: Fix transport header offset in _decode_session6.")
Signed-off-by: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/xfrm6_policy.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 48bf5a0..8d2d01b 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -200,6 +200,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 #if IS_ENABLED(CONFIG_IPV6_MIP6)
 		case IPPROTO_MH:
+			offset += ipv6_optlen(exthdr);
 			if (!onlyproto && pskb_may_pull(skb, nh + offset + 3 - skb->data)) {
 				struct ip6_mh *mh;
 
-- 
1.9.1
