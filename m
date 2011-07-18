From: Joe Perches <joe@perches.com>
Subject: [PATCH] tulip: dmfe: Remove old log spamming pr_debugs
Date: Mon, 18 Jul 2011 07:50:33 -0700
Message-ID: <0a5f6c4c4c948dd5ff827bb5c5517294c9410bfc.1311000440.git.joe@perches.com>
References: <201107181440.35886.jdelvare@suse.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jean Delvare <jdelvare@suse.de>,
	Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4116 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067Ab1GROug (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2011 10:50:36 -0400
In-Reply-To: <201107181440.35886.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 726b65ad444d ("tulip: Convert uses of KERN_DEBUG") enabled
some old previously inactive uses of pr_debug converted by
commit dde7c8ef1679 ("tulip/dmfe.c: Use dev_<level> and pr_<level>").

Remove these pr_debugs.

Signed-off-by: Joe Perches <joe@perches.com>
---

On Mon, 2011-07-18 at 14:40 +0200, Jean Delvare wrote:
With debugging messages enabled by default, one user complained [1]
> that his log was spammed with these messages:
> [ 6233.528227] dmfe: tdes0=7fff0000
 
I do not mind at all disabling the default
debugging logging from tulip.

It looks as if some pr_debugs could be
removed as these were commented out at one
time and brought back by commit dde7c8ef.

 drivers/net/tulip/dmfe.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 4685127..9a21ca3 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -879,7 +879,6 @@ static void dmfe_free_tx_pkt(struct DEVICE *dev, struct dmfe_board_info * db)
 	txptr = db->tx_remove_ptr;
 	while(db->tx_packet_cnt) {
 		tdes0 = le32_to_cpu(txptr->tdes0);
-		pr_debug("tdes0=%x\n", tdes0);
 		if (tdes0 & 0x80000000)
 			break;
 
@@ -889,7 +888,6 @@ static void dmfe_free_tx_pkt(struct DEVICE *dev, struct dmfe_board_info * db)
 
 		/* Transmit statistic counter */
 		if ( tdes0 != 0x7fffffff ) {
-			pr_debug("tdes0=%x\n", tdes0);
 			dev->stats.collisions += (tdes0 >> 3) & 0xf;
 			dev->stats.tx_bytes += le32_to_cpu(txptr->tdes1) & 0x7ff;
 			if (tdes0 & TDES0_ERR_MASK) {
@@ -986,7 +984,6 @@ static void dmfe_rx_packet(struct DEVICE *dev, struct dmfe_board_info * db)
 			/* error summary bit check */
 			if (rdes0 & 0x8000) {
 				/* This is a error packet */
-				pr_debug("rdes0: %x\n", rdes0);
 				dev->stats.rx_errors++;
 				if (rdes0 & 1)
 					dev->stats.rx_fifo_errors++;
@@ -1638,7 +1635,6 @@ static u8 dmfe_sense_speed(struct dmfe_board_info * db)
 		else 				/* DM9102/DM9102A */
 			phy_mode = phy_read(db->ioaddr,
 				    db->phy_addr, 17, db->chip_id) & 0xf000;
-		pr_debug("Phy_mode %x\n", phy_mode);
 		switch (phy_mode) {
 		case 0x1000: db->op_mode = DMFE_10MHF; break;
 		case 0x2000: db->op_mode = DMFE_10MFD; break;
-- 
1.7.6.131.g99019

