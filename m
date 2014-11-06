From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/3 3.18] rtlwifi: Fix errors in descriptor manipulation
Date: Wed,  5 Nov 2014 19:10:53 -0600
Message-ID: <1415236254-12274-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1415236254-12274-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:36973 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbaKFBLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 20:11:20 -0500
In-Reply-To: <1415236254-12274-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are typos in the handling of the descriptor pointers where the wrong
descriptor is referenced. There is also an error in which the pointer is
incremented twice.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/pci.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 116f746..6d2b628 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1375,9 +1375,9 @@ static void _rtl_pci_free_tx_ring(struct ieee80211_hw *hw,
 	ring->desc = NULL;
 	if (rtlpriv->use_new_trx_flow) {
 		pci_free_consistent(rtlpci->pdev,
-				    sizeof(*ring->desc) * ring->entries,
+				    sizeof(*ring->buffer_desc) * ring->entries,
 				    ring->buffer_desc, ring->buffer_desc_dma);
-		ring->desc = NULL;
+		ring->buffer_desc = NULL;
 	}
 }
 
@@ -1548,7 +1548,6 @@ int rtl_pci_reset_trx_ring(struct ieee80211_hw *hw)
 							 true,
 							 HW_DESC_TXBUFF_ADDR),
 						 skb->len, PCI_DMA_TODEVICE);
-				ring->idx = (ring->idx + 1) % ring->entries;
 				kfree_skb(skb);
 				ring->idx = (ring->idx + 1) % ring->entries;
 			}
-- 
2.1.2
