From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [1/6] pasemi_mac: fix build break in pasemi_mac_probe()
Date: Wed, 26 Sep 2007 16:22:43 -0500
Message-ID: <20070926212242.GB24168@lixom.net>
References: <20070926212200.GA24168@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:41579 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758670AbXIZVTd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 17:19:33 -0400
Content-Disposition: inline
In-Reply-To: <20070926212200.GA24168@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: fix build break in pasemi_mac_probe()

Fix breakage caused by recent unification of print_mac() stuff.


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -1155,7 +1155,7 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 	struct net_device *dev;
 	struct pasemi_mac *mac;
 	int err;
-	DECLARE_MAC_BUF(mac);
+	DECLARE_MAC_BUF(mac_buf);
 
 	err = pci_enable_device(pdev);
 	if (err)
@@ -1241,7 +1241,7 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 		       "hw addr %s\n",
 		       dev->name, mac->type == MAC_TYPE_GMAC ? "GMAC" : "XAUI",
 		       mac->dma_if, mac->dma_txch, mac->dma_rxch,
-		       print_mac(mac, dev->dev_addr));
+		       print_mac(mac_buf, dev->dev_addr));
 
 	return err;
 
