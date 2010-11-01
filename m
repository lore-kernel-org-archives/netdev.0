From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 2/2] solos: Refuse to upgrade firmware with older FPGA. It
 doesn't work.
Date: Mon, 01 Nov 2010 16:35:28 -0400
Message-ID: <1288643728.5977.22.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40740 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434Ab0KAUfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 16:35:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index f46138a..40062df 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1161,6 +1161,14 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	dev_info(&dev->dev, "Solos FPGA Version %d.%02d svn-%d\n",
 		 major_ver, minor_ver, fpga_ver);
 
+	if (fpga_ver < 37 && (fpga_upgrade || firmware_upgrade ||
+			      db_fpga_upgrade || db_firmware_upgrade)) {
+		dev_warn(&dev->dev,
+			 "FPGA too old; cannot upgrade flash. Use JTAG.\n");
+		fpga_upgrade = firmware_upgrade = 0;
+		db_fpga_upgrade = db_firmware_upgrade = 0;
+	}
+
 	if (card->fpga_version >= DMA_SUPPORTED){
 		card->using_dma = 1;
 	} else {
-- 
1.7.3.1


