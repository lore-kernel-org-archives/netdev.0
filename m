From: akpm@linux-foundation.org
Subject: [patch 13/13] macb: use random mac if stored address in EEPROM is invalid
Date: Mon, 09 Jun 2008 16:33:57 -0700
Message-ID: <200806092333.m59NXvwH014708@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	svens@stackframe.org, hskinnemoen@atmel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45682 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757150AbYFIXeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 19:34:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Schnelle <svens@stackframe.org>

We should use a random mac address if the EEPROM doesn't contain a valid
one. This makes life on Boards with unprogrammed EEPROM devices easier.

Signed-off-by: Sven Schnelle <svens@stackframe.org>
Cc: Haavard Skinnemoen <hskinnemoen@atmel.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/macb.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff -puN drivers/net/macb.c~macb-use-random-mac-if-stored-address-in-eeprom-is-invalid drivers/net/macb.c
--- a/drivers/net/macb.c~macb-use-random-mac-if-stored-address-in-eeprom-is-invalid
+++ a/drivers/net/macb.c
@@ -80,8 +80,12 @@ static void __init macb_get_hwaddr(struc
 	addr[4] = top & 0xff;
 	addr[5] = (top >> 8) & 0xff;
 
-	if (is_valid_ether_addr(addr))
+	if (is_valid_ether_addr(addr)) {
 		memcpy(bp->dev->dev_addr, addr, sizeof(addr));
+	} else {
+		dev_info(&bp->pdev->dev, "invalid hw address, using random\n");
+		random_ether_addr(bp->dev->dev_addr);
+	}
 }
 
 static int macb_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
_
