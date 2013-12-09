From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 5/5] net: forcedeth: remove unnecessary pci_set_drvdata()
Date: Mon, 09 Dec 2013 12:27:50 +0900
Message-ID: <000701cef48e$a37a7cd0$ea6f7670$%han@samsung.com>
References: <000001cef48e$1ee3c4e0$5cab4ea0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:40452 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760351Ab3LID1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 22:27:51 -0500
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MXI00MEESAEJDA0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Mon, 09 Dec 2013 12:27:50 +0900 (KST)
In-reply-to: <000001cef48e$1ee3c4e0$5cab4ea0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index ab67bab..d8bdaf6 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -6017,7 +6017,6 @@ static int nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 out_error:
 	if (phystate_orig)
 		writel(phystate|NVREG_ADAPTCTL_RUNNING, base + NvRegAdapterControl);
-	pci_set_drvdata(pci_dev, NULL);
 out_freering:
 	free_rings(dev);
 out_unmap:
@@ -6088,7 +6087,6 @@ static void nv_remove(struct pci_dev *pci_dev)
 	pci_release_regions(pci_dev);
 	pci_disable_device(pci_dev);
 	free_netdev(dev);
-	pci_set_drvdata(pci_dev, NULL);
 }
 
 #ifdef CONFIG_PM_SLEEP
-- 
1.7.10.4
