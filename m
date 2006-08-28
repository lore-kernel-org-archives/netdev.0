From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/5] skge: use dev_alloc_skb
Date: Mon, 28 Aug 2006 16:19:37 -0700
Message-ID: <20060828232038.303254635@localhost.localdomain>
References: <20060828231934.477469235@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:33926 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964892AbWH1Xak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 19:30:40 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-alloc-skb.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To avoid problems with buggy protocols that assume extra header space,
use dev_alloc_skb() when allocating receive buffers.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.orig/drivers/net/skge.c
+++ skge-2.6/drivers/net/skge.c
@@ -827,7 +827,8 @@ static int skge_rx_fill(struct skge_port
 	do {
 		struct sk_buff *skb;
 
-		skb = alloc_skb(skge->rx_buf_size + NET_IP_ALIGN, GFP_KERNEL);
+		skb = __dev_alloc_skb(skge->rx_buf_size + NET_IP_ALIGN,
+				      GFP_KERNEL);
 		if (!skb)
 			return -ENOMEM;
 
@@ -2609,7 +2610,7 @@ static inline struct sk_buff *skge_rx_ge
 		goto error;
 
 	if (len < RX_COPY_THRESHOLD) {
-		skb = alloc_skb(len + 2, GFP_ATOMIC);
+		skb = dev_alloc_skb(len + 2);
 		if (!skb)
 			goto resubmit;
 
@@ -2624,7 +2625,7 @@ static inline struct sk_buff *skge_rx_ge
 		skge_rx_reuse(e, skge->rx_buf_size);
 	} else {
 		struct sk_buff *nskb;
-		nskb = alloc_skb(skge->rx_buf_size + NET_IP_ALIGN, GFP_ATOMIC);
+		nskb = dev_alloc_skb(skge->rx_buf_size + NET_IP_ALIGN);
 		if (!nskb)
 			goto resubmit;
 

--
Stephen Hemminger <shemminger@osdl.org>

