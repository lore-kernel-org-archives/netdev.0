From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 11/11] ll_temac: remove unnecessary setting of skb->dev
Date: Mon,  9 Jul 2012 17:09:35 -0700
Message-ID: <1341878975-10577-11-git-send-email-jdmason@kudzu.us>
References: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:42042 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755167Ab2GJAJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 20:09:54 -0400
Received: by mail-gg0-f174.google.com with SMTP id u4so10719391ggl.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 17:09:54 -0700 (PDT)
In-Reply-To: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->dev is being unnecessarily set by the driver on packet recieve.
eth_type_trans already sets skb->dev to the proper value and it is not
referenced anywhere else in the dirver, thus making its setting unnecessary.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/ethernet/xilinx/ll_temac_main.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 1eaf712..705146d 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -768,7 +768,6 @@ static void ll_temac_recv(struct net_device *ndev)
 				 DMA_FROM_DEVICE);
 
 		skb_put(skb, length);
-		skb->dev = ndev;
 		skb->protocol = eth_type_trans(skb, ndev);
 		skb_checksum_none_assert(skb);
 
-- 
1.7.9.5
