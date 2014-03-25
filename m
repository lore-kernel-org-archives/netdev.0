From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 09/54] pcnet32: Call dev_kfree_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:04:55 -0700
Message-ID: <1395727540-12148-9-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:33851 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbaCYGG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:06:28 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_kfree_skb_any in pcnet32_start_xmit
that can be called in hard irq and other contexts.

dev_kfree_skb_any is used as pcnet32_start_xmit only frees an
skb when it drops a packet during transmit.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/amd/pcnet32.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 2ae00ed83afa..e7cc9174e364 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -2448,7 +2448,7 @@ static netdev_tx_t pcnet32_start_xmit(struct sk_buff *skb,
 	lp->tx_dma_addr[entry] =
 	    pci_map_single(lp->pci_dev, skb->data, skb->len, PCI_DMA_TODEVICE);
 	if (pci_dma_mapping_error(lp->pci_dev, lp->tx_dma_addr[entry])) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		dev->stats.tx_dropped++;
 		goto drop_packet;
 	}
-- 
1.7.10.4
