From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/42] atm: solos-pci: Fix set-but-unused variable.
Date: Sun, 17 Apr 2011 17:32:42 -0700 (PDT)
Message-ID: <20110417.173242.189701215.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40533
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752445Ab1DRAdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:33:17 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2E53224C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:32:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is just a readback to entire completion of a register
write, keep the readback but kill the unused variable.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/atm/solos-pci.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index cd0ff66..5d1d076 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -527,7 +527,6 @@ static int flash_upgrade(struct solos_card *card, int chip)
 {
 	const struct firmware *fw;
 	const char *fw_name;
-	uint32_t data32 = 0;
 	int blocksize = 0;
 	int numblocks = 0;
 	int offset;
@@ -576,7 +575,7 @@ static int flash_upgrade(struct solos_card *card, int chip)
 	
 	dev_info(&card->dev->dev, "Changing FPGA to Update mode\n");
 	iowrite32(1, card->config_regs + FPGA_MODE);
-	data32 = ioread32(card->config_regs + FPGA_MODE); 
+	(void) ioread32(card->config_regs + FPGA_MODE); 
 
 	/* Set mode to Chip Erase */
 	if(chip == 0 || chip == 2)
-- 
1.7.4.3

