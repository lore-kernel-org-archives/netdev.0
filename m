From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 2/8] sfc: Fix missing cleanup in failure path of
 efx_pci_probe()
Date: Thu, 10 May 2012 03:28:12 +0100
Message-ID: <1336616892.2499.34.camel@bwh-desktop.uk.solarflarecom.com>
References: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51856 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751668Ab2EJC2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 22:28:16 -0400
In-Reply-To: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to clear the private data pointer in the PCI device.
Also reorder cleanup in efx_pci_remove() for symmetry.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 5cc58a3..8253d21 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2497,8 +2497,8 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 	efx_fini_io(efx);
 	netif_dbg(efx, drv, efx->net_dev, "shutdown successful\n");
 
-	pci_set_drvdata(pci_dev, NULL);
 	efx_fini_struct(efx);
+	pci_set_drvdata(pci_dev, NULL);
 	free_netdev(efx->net_dev);
 };
 
@@ -2700,6 +2700,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
  fail2:
 	efx_fini_struct(efx);
  fail1:
+	pci_set_drvdata(pci_dev, NULL);
 	WARN_ON(rc > 0);
 	netif_dbg(efx, drv, efx->net_dev, "initialisation failed. rc=%d\n", rc);
 	free_netdev(net_dev);
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
