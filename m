From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 11/13] xfrm: Export xfrm_parse_spi.
Date: Thu, 16 Feb 2017 13:18:45 +0100
Message-ID: <1487247527-17925-12-git-send-email-steffen.klassert@secunet.com>
References: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49320 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754695AbdBPMTA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:19:00 -0500
In-Reply-To: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need it in the ESP offload handlers, so export it.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h    | 1 +
 net/xfrm/xfrm_input.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 287635d..fe8db3d 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1520,6 +1520,7 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 		    int encap_type);
 int xfrm4_transport_finish(struct sk_buff *skb, int async);
 int xfrm4_rcv(struct sk_buff *skb);
+int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq);
 
 static inline int xfrm4_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 {
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index d8f913b..86f8a8d 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -170,6 +170,7 @@ int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq)
 	*seq = *(__be32 *)(skb_transport_header(skb) + offset_seq);
 	return 0;
 }
+EXPORT_SYMBOL(xfrm_parse_spi);
 
 int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb)
 {
-- 
1.9.1
