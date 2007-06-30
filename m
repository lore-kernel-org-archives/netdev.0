From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] dm9601: Return 0 from bind() on success
Date: Sat, 30 Jun 2007 23:07:42 +0200
Message-ID: <87y7i1p2w1.fsf@p4.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp40.mobistarmail.be ([193.252.23.61]:59502 "EHLO
	smtp40.mobistarmail.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278AbXF3VHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 17:07:20 -0400
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf4017.mobistarmail.be (SMTP Server) with ESMTP id 5A2747000091
	for <netdev@vger.kernel.org>; Sat, 30 Jun 2007 23:07:18 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fixup dm9601_bind() so it returns 0 on success rather than just a positive
number, as otherwise usbnet doesn't init the status handler.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

---
 drivers/net/usb/dm9601.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

Index: linux-2.6.22-rc6/drivers/net/usb/dm9601.c
===================================================================
--- linux-2.6.22-rc6.orig/drivers/net/usb/dm9601.c
+++ linux-2.6.22-rc6/drivers/net/usb/dm9601.c
@@ -414,18 +414,16 @@
 	dev->mii.reg_num_mask = 0x1f;
 
 	/* reset */
-	ret = dm_write_reg(dev, DM_NET_CTRL, 1);
+	dm_write_reg(dev, DM_NET_CTRL, 1);
 	udelay(20);
 
 	/* read MAC */
-	ret = dm_read(dev, DM_PHY_ADDR, ETH_ALEN, dev->net->dev_addr);
-	if (ret < 0) {
+	if (dm_read(dev, DM_PHY_ADDR, ETH_ALEN, dev->net->dev_addr) < 0) {
 		printk(KERN_ERR "Error reading MAC address\n");
 		ret = -ENODEV;
 		goto out;
 	}
 
-
 	/* power up phy */
 	dm_write_reg(dev, DM_GPR_CTRL, 1);
 	dm_write_reg(dev, DM_GPR_DATA, 0);

-- 
Bye, Peter Korsgaard

