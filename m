From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 58/75] via-velocity: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:30 +0100
Message-ID: <1313760467-8598-58-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/via-velocity.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index deb1eca..af9fb0a 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2571,9 +2571,10 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-		tdinfo->skb_dma[i + 1] = pci_map_page(vptr->pdev, frag->page,
-				frag->page_offset, frag->size,
-				PCI_DMA_TODEVICE);
+		tdinfo->skb_dma[i + 1] = skb_frag_dma_map(&vptr->pdev->dev,
+							  frag, 0,
+							  frag->size,
+							  PCI_DMA_TODEVICE);
 
 		td_ptr->td_buf[i + 1].pa_low = cpu_to_le32(tdinfo->skb_dma[i + 1]);
 		td_ptr->td_buf[i + 1].pa_high = 0;
-- 
1.7.2.5
