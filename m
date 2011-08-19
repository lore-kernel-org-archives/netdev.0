From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 22/75] cxgb3: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:26:54 +0100
Message-ID: <1313760467-8598-22-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Divy Le Ray <divy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Divy Le Ray <divy@chelsio.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/cxgb3/sge.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index d6fa177..a0baaa0 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -979,8 +979,8 @@ static inline unsigned int make_sgl(const struct sk_buff *skb,
 	for (i = 0; i < nfrags; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-		mapping = pci_map_page(pdev, frag->page, frag->page_offset,
-				       frag->size, PCI_DMA_TODEVICE);
+		mapping = skb_frag_dma_map(&pdev->dev, frag, 0, frag->size,
+					   PCI_DMA_TODEVICE);
 		sgp->len[j] = cpu_to_be32(frag->size);
 		sgp->addr[j] = cpu_to_be64(mapping);
 		j ^= 1;
@@ -2116,7 +2116,7 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 	len -= offset;
 
 	rx_frag += nr_frags;
-	rx_frag->page = sd->pg_chunk.page;
+	__skb_frag_set_page(rx_frag, sd->pg_chunk.page);
 	rx_frag->page_offset = sd->pg_chunk.offset + offset;
 	rx_frag->size = len;
 
-- 
1.7.2.5
