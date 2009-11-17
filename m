From: akpm@linux-foundation.org
Subject: [patch 1/1] drivers/atm/solos-pci.c: fix warning/bug, clean up code
Date: Tue, 17 Nov 2009 14:46:44 -0800
Message-ID: <200911172246.nAHMkiK2004221@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	David.Woodhouse@intel.com, chas@cmf.nrl.navy.mil,
	nathan@traverse.com.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52436 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756594AbZKQWr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 17:47:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

drivers/atm/solos-pci.c: In function 'flash_upgrade':
drivers/atm/solos-pci.c:528: warning: 'fw_name' may be used uninitialized in this function

Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Cc: David Woodhouse <David.Woodhouse@intel.com>
Cc: Nathan Williams <nathan@traverse.com.au>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/atm/solos-pci.c |   29 ++++++++++++++++-------------
 1 file changed, 16 insertions(+), 13 deletions(-)

diff -puN drivers/atm/solos-pci.c~drivers-atm-solos-pcic-fix-warning-bug-clean-up-code drivers/atm/solos-pci.c
--- a/drivers/atm/solos-pci.c~drivers-atm-solos-pcic-fix-warning-bug-clean-up-code
+++ a/drivers/atm/solos-pci.c
@@ -531,34 +531,37 @@ static int flash_upgrade(struct solos_ca
 	int numblocks = 0;
 	int offset;
 
-	if (chip == 0) {
+	switch (chip) {
+	case 0:
 		fw_name = "solos-FPGA.bin";
 		blocksize = FPGA_BLOCK;
-	} 
-	
-	if (chip == 1) {
+		break;
+	case 1:
 		fw_name = "solos-Firmware.bin";
 		blocksize = SOLOS_BLOCK;
-	}
-	
-	if (chip == 2){
+		break;
+	case 2:
 		if (card->fpga_version > LEGACY_BUFFERS){
 			fw_name = "solos-db-FPGA.bin";
 			blocksize = FPGA_BLOCK;
 		} else {
-			dev_info(&card->dev->dev, "FPGA version doesn't support daughter board upgrades\n");
+			dev_info(&card->dev->dev, "FPGA version doesn't support"
+					" daughter board upgrades\n");
 			return -EPERM;
 		}
-	}
-	
-	if (chip == 3){
+		break;
+	case 3:
 		if (card->fpga_version > LEGACY_BUFFERS){
 			fw_name = "solos-Firmware.bin";
 			blocksize = SOLOS_BLOCK;
 		} else {
-		dev_info(&card->dev->dev, "FPGA version doesn't support daughter board upgrades\n");
-		return -EPERM;
+			dev_info(&card->dev->dev, "FPGA version doesn't support"
+					" daughter board upgrades\n");
+			return -EPERM;
 		}
+		break;
+	default:
+		return -ENODEV;
 	}
 
 	if (request_firmware(&fw, fw_name, &card->dev->dev))
_
