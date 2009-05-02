From: Lubomir Rintel <lkundrak@v3.sk>
Subject: [PATCH] Do not register ne2k-pci device until initialized
Date: Sat, 02 May 2009 18:28:54 +0200
Message-ID: <1241281735.2641.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from norkia.v3.sk ([92.240.234.41]:39108 "EHLO norkia.v3.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754405AbZEBQxu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 May 2009 12:53:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Doing it in reverse order causes uevent to be sent before
we have a MAC address, which confuses udev.

Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
---
 drivers/net/ne2k-pci.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ne2k-pci.c b/drivers/net/ne2k-pci.c
index eb66f65..7d83896 100644
--- a/drivers/net/ne2k-pci.c
+++ b/drivers/net/ne2k-pci.c
@@ -374,18 +374,17 @@ static int __devinit ne2k_pci_init_one (struct pci_dev *pdev,
 	dev->ethtool_ops = &ne2k_pci_ethtool_ops;
 	NS8390_init(dev, 0);
 
+	memcpy(dev->dev_addr, SA_prom, 6);
+	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
+
 	i = register_netdev(dev);
 	if (i)
 		goto err_out_free_netdev;
 
-	for(i = 0; i < 6; i++)
-		dev->dev_addr[i] = SA_prom[i];
 	printk("%s: %s found at %#lx, IRQ %d, %pM.\n",
 	       dev->name, pci_clone_list[chip_idx].name, ioaddr, dev->irq,
 	       dev->dev_addr);
 
-	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
-
 	return 0;
 
 err_out_free_netdev:

-- 
"Excuse all the blood" -- Dead

