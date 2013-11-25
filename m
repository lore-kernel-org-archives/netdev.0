From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 1/5] net: sfc: remove unnecessary pci_set_drvdata()
Date: Mon, 25 Nov 2013 10:43:09 +0900
Message-ID: <000101cee97f$b2271ff0$16755fd0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	linux-net-drivers@solarflare.com,
	'Ben Hutchings' <bhutchings@solarflare.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:46066 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749Ab3KYBnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 20:43:11 -0500
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWS0034OQ3YSVB0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Mon, 25 Nov 2013 10:43:10 +0900 (KST)
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
index 2e27837..ad6b811 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2641,7 +2641,6 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 	netif_dbg(efx, drv, efx->net_dev, "shutdown successful\n");
 
 	efx_fini_struct(efx);
-	pci_set_drvdata(pci_dev, NULL);
 	free_netdev(efx->net_dev);
 
 	pci_disable_pcie_error_reporting(pci_dev);
@@ -2835,7 +2834,6 @@ static int efx_pci_probe(struct pci_dev *pci_dev,
  fail2:
 	efx_fini_struct(efx);
  fail1:
-	pci_set_drvdata(pci_dev, NULL);
 	WARN_ON(rc > 0);
 	netif_dbg(efx, drv, efx->net_dev, "initialisation failed. rc=%d\n", rc);
 	free_netdev(net_dev);
-- 
1.7.10.4
