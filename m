From: Kyle McMartin <kyle@parisc-linux.org>
Subject: [PATCH 2/9] [TULIP] Print physical address in tulip_init_one
Date: Mon, 07 Aug 2006 20:53:25 +0000
Message-ID: <11549840321096-git-send-email-kyle@parisc-linux.org>
References: <20060807204418.GE401@athena.road.mcmartin.ca> <11549840122892-git-send-email-kyle@parisc-linux.org>
Reply-To: Kyle McMartin <kyle@parisc-linux.org>
Cc: grundler@parisc-linux.org, val_henson@linux.intel.com,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:58753 "EHLO hera.kernel.org")
	by vger.kernel.org with ESMTP id S932272AbWHGU5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 16:57:04 -0400
To: netdev@vger.kernel.org
In-Reply-To: <11549840122892-git-send-email-kyle@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@parisc-linux.org>

As the cookie returned by pci_iomap() is fairly useless...

Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>
---
 drivers/net/tulip/tulip_core.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 7351831..bf93679 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1644,8 +1644,14 @@ #endif
 	if (register_netdev(dev))
 		goto err_out_free_ring;
 
-	printk(KERN_INFO "%s: %s rev %d at %p,",
-	       dev->name, chip_name, chip_rev, ioaddr);
+	printk(KERN_INFO "%s: %s rev %d at "
+#ifdef CONFIG_TULIP_MMIO
+		"MMIO"
+#else
+		"Port"
+#endif
+		" 0x%lx,", dev->name, chip_name, chip_rev,
+		pci_resource_start(pdev, TULIP_BAR));
 	pci_set_drvdata(pdev, dev);
 
 	if (eeprom_missing)
-- 
1.4.1.1

