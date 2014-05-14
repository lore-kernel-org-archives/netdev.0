From: Markus Lottmann <markus.lottmann1986@gmail.com>
Subject: [PATCH] drivers: net: Register Micrel ksz884x network devices in PCI device tree.
Date: Wed, 14 May 2014 14:02:04 +0200
Message-ID: <1400068924-13617-1-git-send-email-markus.lottmann1986@gmail.com>
Cc: netdev@vger.kernel.org,
	Markus Lottmann <markus.lottmann1986@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f67.google.com ([74.125.83.67]:58729 "EHLO
	mail-ee0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbaENMEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 08:04:31 -0400
Received: by mail-ee0-f67.google.com with SMTP id t10so874035eei.2
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 05:04:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This unifies the behaviour with other network device drivers and
allows for a matching of the PCI device path in UDEV rules.

Signed-off-by: Markus Lottmann <markus.lottmann1986@gmail.com>
---
 drivers/net/ethernet/micrel/ksz884x.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 14ac0e2..023f2f9 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -7072,6 +7072,7 @@ static int pcidev_init(struct pci_dev *pdev, const struct pci_device_id *id)
 		dev = alloc_etherdev(sizeof(struct dev_priv));
 		if (!dev)
 			goto pcidev_init_reg_err;
+		SET_NETDEV_DEV(dev, &pdev->dev);
 		info->netdev[i] = dev;
 
 		priv = netdev_priv(dev);
-- 
1.7.10.4
