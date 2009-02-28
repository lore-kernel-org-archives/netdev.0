From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 4/4] jme: Adding {64,40}bits DMA mask back
Date: Sat, 28 Feb 2009 11:59:44 +0800
Message-ID: <20090228035945.M80658@cooldavid.org>
References: <20080915165101.M68109@cooldavid.org> <48D27CDA.50501@pobox.com> <20081008215853.M53590@cooldavid.org>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
Cc: netdev@vger.kernel.org, Ethan <ethanhsiao@jmicron.com>
To: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:46809 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753906AbZB1EBA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 23:01:00 -0500
In-Reply-To: <20081008215853.M53590@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All JMC250 chips have no problem with higher bits support.
Adding it back.

Found-by: Ethan Hsiao <ethanhsiao@jmicron.com>
Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 47dd47f..4da81a3 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2589,6 +2589,16 @@ static const struct ethtool_ops jme_ethtool_ops = {
 static int
 jme_pci_dma64(struct pci_dev *pdev)
 {
+	if (pdev->device == PCI_DEVICE_ID_JMICRON_JMC250 &&
+	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK))
+		if (!pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))
+			return 1;
+
+	if (pdev->device == PCI_DEVICE_ID_JMICRON_JMC250 &&
+	    !pci_set_dma_mask(pdev, DMA_40BIT_MASK))
+		if (!pci_set_consistent_dma_mask(pdev, DMA_40BIT_MASK))
+			return 1;
+
 	if (!pci_set_dma_mask(pdev, DMA_32BIT_MASK))
 		if (!pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))
 			return 0;

