From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 1/5] net: sfc: remove unnecessary pci_set_drvdata()
Date: Mon, 09 Dec 2013 12:24:07 +0900
Message-ID: <000001cef48e$1ee3c4e0$5cab4ea0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	linux-net-drivers@solarflare.com,
	'Ben Hutchings' <bhutchings@solarflare.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:57981 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760297Ab3LIDYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 22:24:09 -0500
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MXI00JJSS48NC80@mailout1.samsung.com> for
 netdev@vger.kernel.org; Mon, 09 Dec 2013 12:24:08 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/sfc/efx.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 958d8c7..12f60e7 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2643,7 +2643,6 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 	netif_dbg(efx, drv, efx->net_dev, "shutdown successful\n");
 
 	efx_fini_struct(efx);
-	pci_set_drvdata(pci_dev, NULL);
 	free_netdev(efx->net_dev);
 
 	pci_disable_pcie_error_reporting(pci_dev);
@@ -2837,7 +2836,6 @@ static int efx_pci_probe(struct pci_dev *pci_dev,
  fail2:
 	efx_fini_struct(efx);
  fail1:
-	pci_set_drvdata(pci_dev, NULL);
 	WARN_ON(rc > 0);
 	netif_dbg(efx, drv, efx->net_dev, "initialisation failed. rc=%d\n", rc);
 	free_netdev(net_dev);
-- 
1.7.10.4
