From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] atm/idt77105.c: fix section mismatch
Date: Sat, 19 Jan 2008 15:18:49 +0200
Message-ID: <20080119131849.GA8669@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: chas@cmf.nrl.navy.mil, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:51584 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752284AbYASNUE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jan 2008 08:20:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EXPORT_SYMBOL'ed code mustn't be __*init.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
--- linux-2.6/drivers/atm/idt77105.c.old	2008-01-19 11:19:53.000000000 +0200
+++ linux-2.6/drivers/atm/idt77105.c	2008-01-19 11:20:10.000000000 +0200
@@ -354,13 +354,13 @@ static const struct atmphy_ops idt77105_
 	.ioctl =	idt77105_ioctl,
 	.interrupt =	idt77105_int,
 	.stop =		idt77105_stop,
 };
 
 
-int __devinit idt77105_init(struct atm_dev *dev)
+int idt77105_init(struct atm_dev *dev)
 {
 	dev->phy = &idt77105_ops;
 	return 0;
 }
 
 EXPORT_SYMBOL(idt77105_init);

