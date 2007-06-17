From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] Fix stupid wol variable overflow bug
Date: Sun, 17 Jun 2007 13:40:03 +0200
Message-ID: <200706171340.04090.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Maximilian Engelhardt <maxi@daemonizer.de>,
	Gary Zambrano <zambrano@broadcom.com>
To: John Linville <linville@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:47057
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755253AbXFQLl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2007 07:41:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This bug was introduced by me.
val is 16bit, but the read value is 32bit.
Seems like I was smoking crack when porting that part of the driver.
I guess that's the last stupid bug in these 4 lines of code.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: bu3sch-wireless-dev/drivers/net/b44.c
===================================================================
--- bu3sch-wireless-dev.orig/drivers/net/b44.c	2007-06-16 19:56:41.000000000 +0200
+++ bu3sch-wireless-dev/drivers/net/b44.c	2007-06-17 13:35:23.000000000 +0200
@@ -1574,8 +1574,7 @@ static void b44_setup_wol_pci(struct b44
 	u16 val;
 
 	if (bp->sdev->bus->bustype != SSB_BUSTYPE_SSB) {
-		val = br32(bp, SSB_TMSLOW);
-		bw32(bp, SSB_TMSLOW, val | SSB_TMSLOW_PE);
+		bw32(bp, SSB_TMSLOW, br32(bp, SSB_TMSLOW) | SSB_TMSLOW_PE);
 		pci_read_config_word(bp->sdev->bus->host_pci, SSB_PMCSR, &val);
 		pci_write_config_word(bp->sdev->bus->host_pci, SSB_PMCSR, val | SSB_PE);
 	}

Please apply this to wireless-dev.

-- 
Greetings Michael.
