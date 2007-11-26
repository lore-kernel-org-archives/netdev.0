From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH 4/4] atm/ambassador: kmalloc + memset conversion to kzalloc
Date: Mon, 26 Nov 2007 18:02:43 +0900
Message-ID: <007f01c8300b$1b89ac40$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>, <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:60035 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754433AbXKZJCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 04:02:51 -0500
Received: by wa-out-1112.google.com with SMTP id v27so658368wah
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2007 01:02:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

atm/ambassador: kmalloc + memset conversion to kzalloc

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>

Thanks.
Joonwoo

---
diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index b34b382..4f99ba3 100644
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
---

