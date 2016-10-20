From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: ethernet: mediatek: use dev_kfree_skb_any instead of dev_kfree_skb
Date: Thu, 20 Oct 2016 17:00:32 +0000
Message-ID: <1476982832-27932-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org
To: Felix Fietkau <nbd@openwrt.org>, John Crispin <blogic@openwrt.org>,
        Matthias Brugger <matthias.bgg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35342 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752463AbcJTRAq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 13:00:46 -0400
Received: by mail-pf0-f193.google.com with SMTP id s8so6070026pfj.2
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 10:00:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Replace dev_kfree_skb with dev_kfree_skb_any in mtk_start_xmit()
which can be called from hard irq context (netpoll) and from
other contexts. mtk_start_xmit() only frees skbs that it has
dropped.

This is detected by Coccinelle semantic patch.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 8f80e61..d716274 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -843,7 +843,7 @@ static int mtk_start_xmit(struct sk_buff *skb, struct net_device *dev)
 drop:
 	spin_unlock(&eth->page_lock);
 	stats->tx_dropped++;
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 	return NETDEV_TX_OK;
 }
 
