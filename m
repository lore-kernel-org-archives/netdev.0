From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 27/75] forcedeth: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:26:59 +0100
Message-ID: <1313760467-8598-27-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	David Decotigny <decot@google.com>,
	Jiri Pirko <jpirko@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Joe Perches <joe@perches.com>
Cc: Szymon Janc <szymon@janc.net.pl>
Cc: David Decotigny <decot@google.com>
Cc: Jiri Pirko <jpirko@redhat.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/forcedeth.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index e55df30..04db866 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2146,8 +2146,11 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			prev_tx = put_tx;
 			prev_tx_ctx = np->put_tx_ctx;
 			bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
-			np->put_tx_ctx->dma = pci_map_page(np->pci_dev, frag->page, frag->page_offset+offset, bcnt,
-							   PCI_DMA_TODEVICE);
+			np->put_tx_ctx->dma = skb_frag_dma_map(
+							&np->pci_dev->dev,
+							frag, offset,
+							bcnt,
+							PCI_DMA_TODEVICE);
 			np->put_tx_ctx->dma_len = bcnt;
 			np->put_tx_ctx->dma_single = 0;
 			put_tx->buf = cpu_to_le32(np->put_tx_ctx->dma);
@@ -2257,8 +2260,11 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 			prev_tx = put_tx;
 			prev_tx_ctx = np->put_tx_ctx;
 			bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
-			np->put_tx_ctx->dma = pci_map_page(np->pci_dev, frag->page, frag->page_offset+offset, bcnt,
-							   PCI_DMA_TODEVICE);
+			np->put_tx_ctx->dma = skb_frag_dma_map(
+							&np->pci_dev->dev,
+							frag, offset,
+							bcnt,
+							PCI_DMA_TODEVICE);
 			np->put_tx_ctx->dma_len = bcnt;
 			np->put_tx_ctx->dma_single = 0;
 			put_tx->bufhigh = cpu_to_le32(dma_high(np->put_tx_ctx->dma));
-- 
1.7.2.5
