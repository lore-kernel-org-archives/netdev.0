From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 26/30] solos: Set RX empty flag at startup only for !dma
 mode
Date: Tue, 17 Mar 2009 21:29:34 +0000
Message-ID: <1237325374.27681.355.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37674 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757803AbZCQV3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:48 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgr4-0001wC-0C
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:46 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index df01682..7c26bd2 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1090,8 +1090,6 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 		iowrite32(0, card->config_regs + FPGA_MODE);
 		data32 = ioread32(card->config_regs + FPGA_MODE); 
 	}
-	//Set RX empty flags
-	iowrite32(0xF0, card->config_regs + FLAGS_ADDR);
 
 	data32 = ioread32(card->config_regs + FPGA_VER);
 	fpga_ver = (data32 & 0x0000FFFF);
@@ -1102,6 +1100,10 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 
 	if (fpga_ver > 27)
 		card->using_dma = 1;
+	else {
+		/* Set RX empty flag for all ports */
+		iowrite32(0xF0, card->config_regs + FLAGS_ADDR);
+	}
 
 	card->nr_ports = 2; /* FIXME: Detect daughterboard */
 
-- 
1.6.0.6


