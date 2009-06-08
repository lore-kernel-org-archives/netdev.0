From: Riccardo Ghetta <birrachiara@tin.it>
Subject: [PATCH] sis190: fix for x86_64 (bug 11509)
Date: Mon, 8 Jun 2009 07:47:58 +0200
Message-ID: <20090608054758.GA21975@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsmtp1.tin.it ([212.216.176.141]:52993 "EHLO vsmtp1.tin.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751467AbZFHFrv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2009 01:47:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corrected dma sync handling on small packets. Should fix 
http://bugzilla.kernel.org/show_bug.cgi?id=11509
Note:
While this bug was reported only on x86_64, it could have affected
any architecture.

Signed-off-by: Riccardo Ghetta <birrachiara@tin.it>
---
 drivers/net/sis190.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index f0d73ab..8a98524 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -540,8 +540,8 @@ static bool sis190_try_rx_copy(struct sis190_private *tp,
 	if (!skb)
 		goto out;
 
-	pci_dma_sync_single_for_device(tp->pci_dev, addr, pkt_size,
-				       PCI_DMA_FROMDEVICE);
+	pci_dma_sync_single_for_cpu(tp->pci_dev, addr, tp->rx_buf_sz,
+				PCI_DMA_FROMDEVICE);
 	skb_reserve(skb, 2);
 	skb_copy_to_linear_data(skb, sk_buff[0]->data, pkt_size);
 	*sk_buff = skb;
-- 
1.6.2.4

