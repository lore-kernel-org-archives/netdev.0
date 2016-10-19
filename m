From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: arc_emac: use dev_kfree_skb_any instead of dev_kfree_skb
Date: Wed, 19 Oct 2016 13:47:52 +0000
Message-ID: <1476884872-15213-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Caesar Wang <wxt@rock-chips.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexander Kochetkov <al.kochet@gmail.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Peter Chen <peter.chen@nxp.com>,
        Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35182 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942056AbcJSOqt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 10:46:49 -0400
Received: by mail-pf0-f196.google.com with SMTP id s8so2676847pfj.2
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 07:46:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Replace dev_kfree_skb with dev_kfree_skb_any in arc_emac_tx()
which can be called from hard irq context (netpoll) and from
other contexts. arc_emac_tx() only frees skbs that it has
dropped.

This is detected by Coccinelle semantic patch.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/arc/emac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index b0da969..95d8b3e 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -633,7 +633,7 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 	if (unlikely(dma_mapping_error(&ndev->dev, addr))) {
 		stats->tx_dropped++;
 		stats->tx_errors++;
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 	dma_unmap_addr_set(&priv->tx_buff[*txbd_curr], addr, addr);
