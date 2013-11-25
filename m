From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 5/5] net: forcedeth: remove unnecessary pci_set_drvdata()
Date: Mon, 25 Nov 2013 10:47:56 +0900
Message-ID: <000501cee980$5cdd3650$1697a2f0$%han@samsung.com>
References: <000101cee97f$b2271ff0$16755fd0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:47246 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752352Ab3KYBr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 20:47:58 -0500
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWS003ZOQBXSJB0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Mon, 25 Nov 2013 10:47:57 +0900 (KST)
In-reply-to: <000101cee97f$b2271ff0$16755fd0$%han@samsung.com>
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
index 2d045be..48df587 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -6018,7 +6018,6 @@ static int nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 out_error:
 	if (phystate_orig)
 		writel(phystate|NVREG_ADAPTCTL_RUNNING, base + NvRegAdapterControl);
-	pci_set_drvdata(pci_dev, NULL);
 out_freering:
 	free_rings(dev);
 out_unmap:
@@ -6089,7 +6088,6 @@ static void nv_remove(struct pci_dev *pci_dev)
 	pci_release_regions(pci_dev);
 	pci_disable_device(pci_dev);
 	free_netdev(dev);
-	pci_set_drvdata(pci_dev, NULL);
 }
 
 #ifdef CONFIG_PM_SLEEP
-- 
1.7.10.4
