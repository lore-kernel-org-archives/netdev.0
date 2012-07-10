From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 01/11] lance: remove unnecessary setting of skb->dev
Date: Mon,  9 Jul 2012 17:09:25 -0700
Message-ID: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56424 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755148Ab2GJAJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 20:09:03 -0400
Received: by pbbrp8 with SMTP id rp8so20018595pbb.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 17:09:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->dev is being unnecessarily set during ring init.  It is already being set
to the proper value when eth_type_trans is called on packet receive, and the
skb->dev is not referenced anywhere else in the code.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/ethernet/amd/lance.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/lance.c b/drivers/net/ethernet/amd/lance.c
index a6e2e84..5c72843 100644
--- a/drivers/net/ethernet/amd/lance.c
+++ b/drivers/net/ethernet/amd/lance.c
@@ -873,10 +873,9 @@ lance_init_ring(struct net_device *dev, gfp_t gfp)
 
 		skb = alloc_skb(PKT_BUF_SZ, GFP_DMA | gfp);
 		lp->rx_skbuff[i] = skb;
-		if (skb) {
-			skb->dev = dev;
+		if (skb)
 			rx_buff = skb->data;
-		} else
+		else
 			rx_buff = kmalloc(PKT_BUF_SZ, GFP_DMA | gfp);
 		if (rx_buff == NULL)
 			lp->rx_ring[i].base = 0;
-- 
1.7.9.5
