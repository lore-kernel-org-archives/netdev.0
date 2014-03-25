From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 38/54] sis900: Call dev_kfree_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:05:24 -0700
Message-ID: <1395727540-12148-38-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59086 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752296AbaCYGLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:36 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_kfree_skb_any in functions that can
be called in hard irq and other contexts.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/sis/sis900.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index ff57a46388ee..6072f093e6b4 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -1614,7 +1614,7 @@ sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
 		skb->data, skb->len, PCI_DMA_TODEVICE);
 	if (unlikely(pci_dma_mapping_error(sis_priv->pci_dev,
 		sis_priv->tx_ring[entry].bufptr))) {
-			dev_kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 			sis_priv->tx_skbuff[entry] = NULL;
 			net_dev->stats.tx_dropped++;
 			spin_unlock_irqrestore(&sis_priv->lock, flags);
-- 
1.7.10.4
