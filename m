From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/2] e1000: remove risky prefetch on next_skb->data
Date: Mon, 05 Jun 2006 16:11:27 -0700
Message-ID: <20060605231127.12584.14321.stgit@gitlost.site>
References: <20060605230917.12584.55755.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:49158 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1750760AbWFEXGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 19:06:02 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060605230917.12584.55755.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It was brought to our attention that the prefetches break e1000 traffic
on xscale/arm architectures.  Remove them for now.  We'll let them
stay in mm for a while, or find a better solution to enable.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7103a0e..aef616f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3519,7 +3519,7 @@ e1000_clean_rx_irq(struct e1000_adapter 
 	buffer_info = &rx_ring->buffer_info[i];
 
 	while (rx_desc->status & E1000_RXD_STAT_DD) {
-		struct sk_buff *skb, *next_skb;
+		struct sk_buff *skb;
 		u8 status;
 #ifdef CONFIG_E1000_NAPI
 		if (*work_done >= work_to_do)
@@ -3537,8 +3537,6 @@ e1000_clean_rx_irq(struct e1000_adapter 
 		prefetch(next_rxd);
 
 		next_buffer = &rx_ring->buffer_info[i];
-		next_skb = next_buffer->skb;
-		prefetch(next_skb->data - NET_IP_ALIGN);
 
 		cleaned = TRUE;
 		cleaned_count++;
@@ -3668,7 +3666,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
 	struct e1000_buffer *buffer_info, *next_buffer;
 	struct e1000_ps_page *ps_page;
 	struct e1000_ps_page_dma *ps_page_dma;
-	struct sk_buff *skb, *next_skb;
+	struct sk_buff *skb;
 	unsigned int i, j;
 	uint32_t length, staterr;
 	int cleaned_count = 0;
@@ -3697,8 +3695,6 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
 		prefetch(next_rxd);
 
 		next_buffer = &rx_ring->buffer_info[i];
-		next_skb = next_buffer->skb;
-		prefetch(next_skb->data - NET_IP_ALIGN);
 
 		cleaned = TRUE;
 		cleaned_count++;



--
Auke Kok <auke-jan.h.kok@intel.com>
