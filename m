From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 21/75] chelsio: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:26:53 +0100
Message-ID: <1313760467-8598-21-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Paul <paul.gortmaker@windriver.com>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Lucas De Marchi <lucas.demarchi@profusion.mobi>
Cc: Paul <paul.gortmaker@windriver.com>
Cc: Jesse Gross <jesse@nicira.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/chelsio/sge.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index e9a03ff..7cde425 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1277,9 +1277,8 @@ static inline void write_tx_descs(struct adapter *adapter, struct sk_buff *skb,
 			ce = q->centries;
 		}
 
-		mapping = pci_map_page(adapter->pdev, frag->page,
-				       frag->page_offset, frag->size,
-				       PCI_DMA_TODEVICE);
+		mapping = skb_frag_dma_map(&adapter->pdev->dev, frag, 0,
+					   frag->size, PCI_DMA_TODEVICE);
 		desc_mapping = mapping;
 		desc_len = frag->size;
 
-- 
1.7.2.5
