From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 11/75] 8139cp: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:26:43 +0100
Message-ID: <1313760467-8598-11-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/8139cp.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index cc4c210..abefdce 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -784,8 +784,7 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 
 			len = this_frag->size;
 			mapping = dma_map_single(&cp->pdev->dev,
-						 ((void *) page_address(this_frag->page) +
-						  this_frag->page_offset),
+						 skb_frag_address(this_frag),
 						 len, PCI_DMA_TODEVICE);
 			eor = (entry == (CP_TX_RING_SIZE - 1)) ? RingEnd : 0;
 
-- 
1.7.2.5
