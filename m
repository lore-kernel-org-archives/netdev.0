From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 23/30] solos: Add 'reset' module parameter to reset the DSL
 chips on load
Date: Tue, 17 Mar 2009 21:29:32 +0000
Message-ID: <1237325372.27681.352.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37671 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757952AbZCQV3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:45 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgqz-0001w3-VW
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:42 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 21c73b1..c54eceb 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -70,6 +70,7 @@
 
 #define RX_DMA_SIZE	2048
 
+static int reset = 0;
 static int atmdebug = 0;
 static int firmware_upgrade = 0;
 static int fpga_upgrade = 0;
@@ -131,9 +132,11 @@ MODULE_AUTHOR("Traverse Technologies <support@traverse.com.au>");
 MODULE_DESCRIPTION("Solos PCI driver");
 MODULE_VERSION(VERSION);
 MODULE_LICENSE("GPL");
+MODULE_PARM_DESC(reset, "Reset Solos chips on startup");
 MODULE_PARM_DESC(atmdebug, "Print ATM data");
 MODULE_PARM_DESC(firmware_upgrade, "Initiate Solos firmware upgrade");
 MODULE_PARM_DESC(fpga_upgrade, "Initiate FPGA upgrade");
+module_param(reset, int, 0444);
 module_param(atmdebug, int, 0644);
 module_param(firmware_upgrade, int, 0444);
 module_param(fpga_upgrade, int, 0444);
@@ -1071,6 +1074,13 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 		goto out_unmap_config;
 	}
 
+	if (reset) {
+		iowrite32(1, card->config_regs + FPGA_MODE);
+		data32 = ioread32(card->config_regs + FPGA_MODE); 
+
+		iowrite32(0, card->config_regs + FPGA_MODE);
+		data32 = ioread32(card->config_regs + FPGA_MODE); 
+	}
 	//Fill Config Mem with zeros
 	for(i = 0; i < 128; i += 4)
 		iowrite32(0, card->config_regs + i);
-- 
1.6.0.6


