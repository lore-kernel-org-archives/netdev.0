From: Michael Opdenacker <michael@free-electrons.com>
Subject: [PATCH 1/1] Minor code cleanup in drivers/net/r6040.c
Date: Thu, 25 Jun 2009 09:05:09 +0200
Message-ID: <1245913509-23245-1-git-send-email-michael@free-electrons.com>
Cc: Michael Opdenacker <michael@free-electrons.com>
To: florian@openwrt.org, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.191.76.200]:58332 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758167AbZFYHMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 03:12:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Replaced '0' by 'bar' in the probe function.
 The 'bar' variable was already set to '0' and is already
 used in pci_iomap(). This is cleaner and improves code
 consistency.

Signed-off-by: Michael Opdenacker <michael@free-electrons.com>
---
 drivers/net/r6040.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index ed63d23..b3197e9 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -1112,13 +1112,13 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	}
 
 	/* IO Size check */
-	if (pci_resource_len(pdev, 0) < io_size) {
+	if (pci_resource_len(pdev, bar) < io_size) {
 		printk(KERN_ERR DRV_NAME ": Insufficient PCI resources, aborting\n");
 		err = -EIO;
 		goto err_out;
 	}
 
-	pioaddr = pci_resource_start(pdev, 0);	/* IO map base address */
+	pioaddr = pci_resource_start(pdev, bar);	/* IO map base address */
 	pci_set_master(pdev);
 
 	dev = alloc_etherdev(sizeof(struct r6040_private));
-- 
1.6.0.4

