From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 12/75] acenic: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:26:44 +0100
Message-ID: <1313760467-8598-12-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Jes Sorensen <jes@trained-monkey.org>, linux-acenic@sunsite.dk
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Jes Sorensen <jes@trained-monkey.org>
Cc: linux-acenic@sunsite.dk
Cc: netdev@vger.kernel.org
---
 drivers/net/acenic.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 31798f5..05df583 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -2485,9 +2485,9 @@ restart:
 			info = ap->skb->tx_skbuff + idx;
 			desc = ap->tx_ring + idx;
 
-			mapping = pci_map_page(ap->pdev, frag->page,
-					       frag->page_offset, frag->size,
-					       PCI_DMA_TODEVICE);
+			mapping = skb_frag_dma_map(&ap->pdev->dev, frag, 0,
+						   frag->size,
+						   PCI_DMA_TODEVICE);
 
 			flagsize = (frag->size << 16);
 			if (skb->ip_summed == CHECKSUM_PARTIAL)
-- 
1.7.2.5
