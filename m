From: roy.qing.li@gmail.com
Subject: [PATCH] sunvnet: fix a memory leak in vnet_handle_offloads
Date: Fri, 19 Dec 2014 13:19:35 +0800
Message-ID: <1418966375-23188-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:34323 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230AbaLSFTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 00:19:41 -0500
Received: by mail-pd0-f180.google.com with SMTP id w10so453294pde.39
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2014 21:19:41 -0800 (PST)
Received: from localhost ([106.120.101.38])
        by mx.google.com with ESMTPSA id do3sm8334285pac.48.2014.12.18.21.19.39
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Dec 2014 21:19:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

when skb_gso_segment returns error, the original skb should be freed

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/ethernet/sun/sunvnet.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 45c408e..d2835bf 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -1201,6 +1201,7 @@ static int vnet_handle_offloads(struct vnet_port *port, struct sk_buff *skb)
 		segs = skb_gso_segment(skb, dev->features & ~NETIF_F_TSO);
 	if (IS_ERR(segs)) {
 		dev->stats.tx_dropped++;
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
-- 
2.1.0
