From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-2.6 2/7] atm: [iphase] set drvdata before enabling interrupts
Date: Mon, 16 Jun 2008 13:27:13 -0400
Message-ID: <200806161727.m5GHRD78003340@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:45505 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643AbYFPR1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 13:27:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 80aabdc78db5888c0b968532dd7d4f4e7510d7a4
Author: Jorge Boncompte [DTI2] <jorge@dti2.net>
Date:   Sat Jun 14 17:08:08 2008 -0400

    atm: [iphase] set drvdata before enabling interrupts
    
    Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 5c28ca7..800c09e 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -3198,6 +3198,8 @@ static int __devinit ia_init_one(struct pci_dev *pdev,
 	IF_INIT(printk("dev_id = 0x%x iadev->LineRate = %d \n", (u32)dev,
 		iadev->LineRate);)
 
+	pci_set_drvdata(pdev, dev);
+
 	ia_dev[iadev_count] = iadev;
 	_ia_dev[iadev_count] = dev;
 	iadev_count++;
@@ -3219,8 +3221,6 @@ static int __devinit ia_init_one(struct pci_dev *pdev,
 	iadev->next_board = ia_boards;  
 	ia_boards = dev;  
 
-	pci_set_drvdata(pdev, dev);
-
 	return 0;
 
 err_out_deregister_dev:
