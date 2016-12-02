From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next 3/5] mlx4: use reset to set mac header
Date: Fri,  2 Dec 2016 09:51:05 +0800
Message-ID: <1480643467-4420-4-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1480643467-4420-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:60013 "EHLO
        cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755759AbcLBBvT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 20:51:19 -0500
In-Reply-To: <1480643467-4420-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since offset is zero, it's not necessary to use set function. Reset
function is straightforward, and will remove the unnecessary add
operation in set function.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
index c06346a..95290e1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
@@ -68,7 +68,7 @@ static int mlx4_en_test_loopback_xmit(struct mlx4_en_priv *priv)
 	memcpy(ethh->h_dest, priv->dev->dev_addr, ETH_ALEN);
 	eth_zero_addr(ethh->h_source);
 	ethh->h_proto = htons(ETH_P_ARP);
-	skb_set_mac_header(skb, 0);
+	skb_reset_mac_header(skb);
 	for (i = 0; i < packet_size; ++i)	/* fill our packet */
 		packet[i] = (unsigned char)(i & 0xff);
 
-- 
1.8.3.1
