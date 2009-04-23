From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] pasemi_mac: mac_to_intf() error not noticed
Date: Thu, 23 Apr 2009 19:44:09 +0200
Message-ID: <49F0A8E9.2010702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Olof Johansson <olof@lixom.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:46717 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005AbZDWRoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 13:44:10 -0400
Received: by ewy24 with SMTP id 24so670875ewy.37
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 10:44:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mac_to_intf() can return -1 when no device or function was found, but when
mac->dma_if is unsigned. The error wasn't noticed.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 5eeb5a8..1857974 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -1798,12 +1798,13 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 	memcpy(dev->dev_addr, mac->mac_addr, sizeof(mac->mac_addr));
 
-	mac->dma_if = mac_to_intf(mac);
-	if (mac->dma_if < 0) {
+	err = mac_to_intf(mac);
+	if (err < 0) {
 		dev_err(&mac->pdev->dev, "Can't map DMA interface\n");
 		err = -ENODEV;
 		goto out;
 	}
+	mac->dma_if = err;
 
 	switch (pdev->device) {
 	case 0xa005:
