From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 57/75] typhoon: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:29 +0100
Message-ID: <1313760467-8598-57-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	David Dillow <dave@thedillows.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: David Dillow <dave@thedillows.org>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/typhoon.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 1d5091a..21f69ca 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -819,8 +819,7 @@ typhoon_start_tx(struct sk_buff *skb, struct net_device *dev)
 			typhoon_inc_tx_index(&txRing->lastWrite, 1);
 
 			len = frag->size;
-			frag_addr = (void *) page_address(frag->page) +
-						frag->page_offset;
+			frag_addr = skb_frag_address(frag);
 			skb_dma = pci_map_single(tp->tx_pdev, frag_addr, len,
 					 PCI_DMA_TODEVICE);
 			txd->flags = TYPHOON_FRAG_DESC | TYPHOON_DESC_VALID;
-- 
1.7.2.5
