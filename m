From: Daniel Hellstrom <daniel@gaisler.com>
Subject: [PATCH 1/1] dl2k: EEPROM CRC calculation wrong endianess on bigendian machine
Date: Fri, 10 Jun 2011 15:16:17 +0200
Message-ID: <1307711777-12119-1-git-send-email-daniel@gaisler.com>
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail202c2.megamailservers.com ([69.49.111.103]:48253 "EHLO
	mail202c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753332Ab1FJNQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 09:16:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
---
 drivers/net/dl2k.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index c445457..4bbbd7b 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -346,7 +346,7 @@ parse_eeprom (struct net_device *dev)
 	if (np->pdev->vendor == PCI_VENDOR_ID_DLINK) {	/* D-Link Only */
 		/* Check CRC */
 		crc = ~ether_crc_le (256 - 4, sromdata);
-		if (psrom->crc != crc) {
+		if (psrom->crc != cpu_to_le32(crc)) {q
 			printk (KERN_ERR "%s: EEPROM data CRC error.\n",
 					dev->name);
 			return -1;
-- 
1.5.4

