From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-2.6.25 6/7][ATM]: [ambassador] kmalloc + memset conversion to kzalloc
Date: Sat, 29 Dec 2007 20:08:12 -0500
Message-ID: <200712300108.lBU18CjE003595@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:59190 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571AbXL3BI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 20:08:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 87c1811be8f1c6587ed3b57d23f93c7e91afdde7
Author: Joonwoo Park <joonwpark81@gmail.com>
Date:   Tue Nov 27 09:43:04 2007 -0500

    [ATM]: [ambassador] kmalloc + memset conversion to kzalloc
    
    Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index b34b382..7b44a59 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -2163,7 +2163,6 @@ static int __devinit amb_init (amb_dev * dev)
 static void setup_dev(amb_dev *dev, struct pci_dev *pci_dev) 
 {
       unsigned char pool;
-      memset (dev, 0, sizeof(amb_dev));
       
       // set up known dev items straight away
       dev->pci_dev = pci_dev; 
@@ -2253,7 +2252,7 @@ static int __devinit amb_probe(struct pci_dev *pci_dev, const struct pci_device_
 		goto out_disable;
 	}
 
-	dev = kmalloc (sizeof(amb_dev), GFP_KERNEL);
+	dev = kzalloc(sizeof(amb_dev), GFP_KERNEL);
 	if (!dev) {
 		PRINTK (KERN_ERR, "out of memory!");
 		err = -ENOMEM;
