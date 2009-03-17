From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 25/30] solos: Don't clear config registers at startup
Date: Tue, 17 Mar 2009 21:29:34 +0000
Message-ID: <1237325374.27681.354.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37673 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758359AbZCQV3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:47 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgr2-0001w9-LO
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:44 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index f27bd92..df01682 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1040,7 +1040,7 @@ static struct atmdev_ops fpga_ops = {
 
 static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 {
-	int err, i;
+	int err;
 	uint16_t fpga_ver;
 	uint8_t major_ver, minor_ver;
 	uint32_t data32;
@@ -1090,10 +1090,6 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 		iowrite32(0, card->config_regs + FPGA_MODE);
 		data32 = ioread32(card->config_regs + FPGA_MODE); 
 	}
-	//Fill Config Mem with zeros
-	for(i = 0; i < 128; i += 4)
-		iowrite32(0, card->config_regs + i);
-
 	//Set RX empty flags
 	iowrite32(0xF0, card->config_regs + FLAGS_ADDR);
 
-- 
1.6.0.6


