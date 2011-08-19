From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 32/75] ksz884x: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:04 +0100
Message-ID: <1313760467-8598-32-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Sedat Dilek <sedat.dilek@gmail.com>,
	Tobias Klauser <tklauser@distanz.ch>,
	David Decotigny <decot@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Sedat Dilek <sedat.dilek@gmail.com>
Cc: Tobias Klauser <tklauser@distanz.ch>
Cc: David Decotigny <decot@google.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ksz884x.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index 27418d3..710c4ae 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -4704,8 +4704,7 @@ static void send_packet(struct sk_buff *skb, struct net_device *dev)
 
 			dma_buf->dma = pci_map_single(
 				hw_priv->pdev,
-				page_address(this_frag->page) +
-				this_frag->page_offset,
+				skb_frag_address(this_frag),
 				dma_buf->len,
 				PCI_DMA_TODEVICE);
 			set_tx_buf(desc, dma_buf->dma);
-- 
1.7.2.5
