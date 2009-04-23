From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] pasemi_mac: mac_to_intf() error not noticed
Date: Thu, 23 Apr 2009 20:53:20 +0200
Message-ID: <49F0B920.1050704@gmail.com>
References: <49F0A8E9.2010702@gmail.com> <20090423175648.GA4406@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:55696 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753524AbZDWSxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 14:53:20 -0400
Received: by ewy24 with SMTP id 24so702097ewy.37
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 11:53:18 -0700 (PDT)
In-Reply-To: <20090423175648.GA4406@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Olof Johansson wrote:
> On Thu, Apr 23, 2009 at 07:44:09PM +0200, Roel Kluin wrote:
> This can in practice never happen which is likely why it went
> unnoticed.

> define a new variable with an appropriate name, please.

Ok, how's this?
--------------------------->8-------------8<------------------------------
mac_to_intf() can return -1 when no device or function is found, but when
mac->dma_if is unsigned. The error wasn't noticed.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 5eeb5a8..1e8f396 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -1740,7 +1740,7 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev;
 	struct pasemi_mac *mac;
-	int err;
+	int err, ret;
 
 	err = pci_enable_device(pdev);
 	if (err)
@@ -1798,12 +1798,13 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 	memcpy(dev->dev_addr, mac->mac_addr, sizeof(mac->mac_addr));
 
-	mac->dma_if = mac_to_intf(mac);
-	if (mac->dma_if < 0) {
+	ret = mac_to_intf(mac);
+	if (ret < 0) {
 		dev_err(&mac->pdev->dev, "Can't map DMA interface\n");
 		err = -ENODEV;
 		goto out;
 	}
+	mac->dma_if = ret;
 
 	switch (pdev->device) {
 	case 0xa005:
