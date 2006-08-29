From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 25/26] ixgb: remove skb->dev assignment
Date: Tue, 29 Aug 2006 09:45:10 -0700
Message-ID: <20060829164510.6872.10310.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:62218 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965097AbWH2Qg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:56 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Same change as e1000: remove skb->dev assignment, it's now done
by netdev_alloc_skb.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index abca75f..ee12a85 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1974,7 +1974,6 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 			    netdev_alloc_skb(netdev, length + NET_IP_ALIGN);
 			if (new_skb) {
 				skb_reserve(new_skb, NET_IP_ALIGN);
-				new_skb->dev = netdev;
 				memcpy(new_skb->data - NET_IP_ALIGN,
 				       skb->data - NET_IP_ALIGN,
 				       length + NET_IP_ALIGN);
@@ -2054,14 +2053,14 @@ ixgb_alloc_rx_buffers(struct ixgb_adapte
 	/* leave three descriptors unused */
 	while(--cleancount > 2) {
 		/* recycle! its good for you */
-		if (!(skb = buffer_info->skb))
-			skb = netdev_alloc_skb(netdev, adapter->rx_buffer_len
-			                    + NET_IP_ALIGN);
-		else {
+		skb = buffer_info->skb;
+		if (skb) {
 			skb_trim(skb, 0);
 			goto map_skb;
 		}
 
+		skb = netdev_alloc_skb(netdev, adapter->rx_buffer_len
+			               + NET_IP_ALIGN);
 		if (unlikely(!skb)) {
 			/* Better luck next round */
 			adapter->alloc_rx_buff_failed++;
@@ -2074,8 +2073,6 @@ ixgb_alloc_rx_buffers(struct ixgb_adapte
 		 */
 		skb_reserve(skb, NET_IP_ALIGN);
 
-		skb->dev = netdev;
-
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_buffer_len;
 map_skb:



---
Auke Kok <auke-jan.h.kok@intel.com>
