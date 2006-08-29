From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 18/26] ixgb: Convert dev_alloc_skb to netdev_alloc_skb.
Date: Tue, 29 Aug 2006 09:44:54 -0700
Message-ID: <20060829164454.6872.66598.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:50186 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965091AbWH2Qgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:41 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 346273d..6959735 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1948,7 +1948,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 #define IXGB_CB_LENGTH 256
 		if (length < IXGB_CB_LENGTH) {
 			struct sk_buff *new_skb =
-			    dev_alloc_skb(length + NET_IP_ALIGN);
+			    netdev_alloc_skb(netdev, length + NET_IP_ALIGN);
 			if (new_skb) {
 				skb_reserve(new_skb, NET_IP_ALIGN);
 				new_skb->dev = netdev;
@@ -2032,7 +2032,7 @@ ixgb_alloc_rx_buffers(struct ixgb_adapte
 	while(--cleancount > 2) {
 		/* recycle! its good for you */
 		if (!(skb = buffer_info->skb))
-			skb = dev_alloc_skb(adapter->rx_buffer_len
+			skb = netdev_alloc_skb(netdev, adapter->rx_buffer_len
 			                    + NET_IP_ALIGN);
 		else {
 			skb_trim(skb, 0);



---
Auke Kok <auke-jan.h.kok@intel.com>
