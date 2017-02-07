From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC ipsec-next 4/5] xfrm: Export xfrm_parse_spi.
Date: Tue, 7 Feb 2017 10:14:10 +0100
Message-ID: <1486458851-4920-5-git-send-email-steffen.klassert@secunet.com>
References: <1486458851-4920-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "Sowmini Varadhan" <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:44810 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753284AbdBGJOY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 04:14:24 -0500
In-Reply-To: <1486458851-4920-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need it in the ESP offload handlers, so export it.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h    | 1 +
 net/xfrm/xfrm_input.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 25082e2..8acea1e 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1522,6 +1522,7 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 		    int encap_type);
 int xfrm4_transport_finish(struct sk_buff *skb, int async);
 int xfrm4_rcv(struct sk_buff *skb);
+int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq);
 
 static inline int xfrm4_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 {
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 58f5e44..538d338 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -180,6 +180,7 @@ int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq)
 	*seq = *(__be32 *)(skb_transport_header(skb) + offset_seq);
 	return 0;
 }
+EXPORT_SYMBOL(xfrm_parse_spi);
 
 int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb)
 {
-- 
1.9.1
