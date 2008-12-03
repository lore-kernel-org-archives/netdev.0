From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-2.6 2/2] jme: Remove 64 and 40 bit dma_mask
Date: Wed, 3 Dec 2008 18:44:32 +0800
Message-ID: <20081203104433.M88858@cooldavid.org>
References: <20080915165101.M68109@cooldavid.org> <48D27CDA.50501@pobox.com> <20081008215853.M53590@cooldavid.org>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
Cc: netdev@vger.kernel.org, Ethan <ethanhsiao@jmicron.com>,
	akeemting <akeem@jmicron.com>
To: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:41200 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751160AbYLCKoi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2008 05:44:38 -0500
In-Reply-To: <20081008215853.M53590@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Jeff, David:

Although the hardware supports the 64bit DMA address in design,
but later found that it actually not working.
This patch reduced the rang to 32bit.

Found-by: "Ethan" <ethanhsiao@jmicron.com>
Signed-off-by: "Guo-Fu Tseng" <cooldavid@cooldavid.org>

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 49090ba..660bb89 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2592,14 +2592,6 @@ static const struct ethtool_ops jme_ethtool_ops = {
 static int
 jme_pci_dma64(struct pci_dev *pdev)
 {
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK))
-		if (!pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))
-			return 1;
-
-	if (!pci_set_dma_mask(pdev, DMA_40BIT_MASK))
-		if (!pci_set_consistent_dma_mask(pdev, DMA_40BIT_MASK))
-			return 1;
-
 	if (!pci_set_dma_mask(pdev, DMA_32BIT_MASK))
 		if (!pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))
 			return 0;

