From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 48/75] skge: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:20 +0100
Message-ID: <1313760467-8598-48-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/skge.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 98ec614..62a189c 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2758,8 +2758,8 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-			map = pci_map_page(hw->pdev, frag->page, frag->page_offset,
-					   frag->size, PCI_DMA_TODEVICE);
+			map = skb_frag_dma_map(&hw->pdev->dev, frag, 0,
+					       frag->size, PCI_DMA_TODEVICE);
 
 			e = e->next;
 			e->skb = skb;
-- 
1.7.2.5
