From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 28/34]bnx2x: Overstepping array bounds
Date: Wed, 14 Jan 2009 18:44:10 +0200
Message-ID: <1231951450.11301.149.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3140 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754096AbZANQpX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:45:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the page size is > 8KB this violation happens

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 0a18af0..cc83388 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -9466,6 +9466,7 @@ static inline u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
 	return rc;
 }
 
+#if (MAX_SKB_FRAGS >= MAX_FETCH_BD - 3)
 /* check if packet requires linearization (packet is too fragmented) */
 static int bnx2x_pkt_req_lin(struct bnx2x *bp, struct sk_buff *skb,
 			     u32 xmit_type)
@@ -9543,6 +9544,7 @@ exit_lbl:
 
 	return to_copy;
 }
+#endif
 
 /* called with netif_tx_lock
  * bnx2x_tx_int() runs without netif_tx_lock unless it needs to call
@@ -9583,6 +9585,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	   skb->ip_summed, skb->protocol, ipv6_hdr(skb)->nexthdr,
 	   ip_hdr(skb)->protocol, skb_shinfo(skb)->gso_type, xmit_type);
 
+#if (MAX_SKB_FRAGS >= MAX_FETCH_BD - 3)
 	/* First, check if we need to linearize the skb
 	   (due to FW restrictions) */
 	if (bnx2x_pkt_req_lin(bp, skb, xmit_type)) {
@@ -9595,6 +9598,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			return NETDEV_TX_OK;
 		}
 	}
+#endif
 
 	/*
 	Please read carefully. First we use one BD which we mark as start,
-- 
1.5.4.3




