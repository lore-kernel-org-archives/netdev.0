From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 29/30] solos: Automatically determine number of ports
Date: Tue, 17 Mar 2009 21:29:37 +0000
Message-ID: <1237325377.27681.359.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37677 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758272AbZCQV3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:52 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgr8-0001wR-5S
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:50 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nathan Williams <nathan@traverse.com.au>
Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 1ff7304..6fe8f8f 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1104,7 +1104,8 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 		iowrite32(0xF0, card->config_regs + FLAGS_ADDR);
 	}
 
-	card->nr_ports = 2; /* FIXME: Detect daughterboard */
+	data32 = ioread32(card->config_regs + PORTS);
+	card->nr_ports = (data32 & 0x000000FF);
 
 	pci_set_drvdata(dev, card);
 
-- 
1.6.0.6


