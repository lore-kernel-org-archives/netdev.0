From: Daniel Hellstrom <daniel@gaisler.com>
Subject: [PATCH v2] dl2k: EEPROM CRC calculation wrong endianess on bigendian machine
Date: Fri, 10 Jun 2011 16:55:16 +0200
Message-ID: <1307717716-13668-1-git-send-email-daniel@gaisler.com>
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail202c2.megamailservers.com ([69.49.111.103]:54768 "EHLO
	mail202c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756427Ab1FJOz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 10:55:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
---
 drivers/net/dl2k.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index c445457..23179db 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -346,7 +346,7 @@ parse_eeprom (struct net_device *dev)
 	if (np->pdev->vendor == PCI_VENDOR_ID_DLINK) {	/* D-Link Only */
 		/* Check CRC */
 		crc = ~ether_crc_le (256 - 4, sromdata);
-		if (psrom->crc != crc) {
+		if (psrom->crc != cpu_to_le32(crc)) {
 			printk (KERN_ERR "%s: EEPROM data CRC error.\n",
 					dev->name);
 			return -1;
-- 
1.5.4

