From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 3/7] vxge: use pci_request_region()
Date: Fri, 10 Dec 2010 18:02:58 -0600
Message-ID: <1292025782-16372-3-git-send-email-jon.mason@exar.com>
References: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:45252 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756503Ab0LKADX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:03:23 -0500
Received: by mail-yw0-f46.google.com with SMTP id 5so2401509ywl.19
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 16:03:23 -0800 (PST)
In-Reply-To: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only BAR0 is ever accessed, thus making the calls to pci_request_regions
overkill.  Change calls of pci_request_regions to pci_request_region to
reduce the size of the mapped area.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 9c68c60..faebffb 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -4325,7 +4325,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 		goto _exit1;
 	}
 
-	if (pci_request_regions(pdev, VXGE_DRIVER_NAME)) {
+	if (pci_request_region(pdev, 0, VXGE_DRIVER_NAME)) {
 		vxge_debug_init(VXGE_ERR,
 			"%s : request regions failed", __func__);
 		ret = -ENODEV;
@@ -4638,7 +4638,7 @@ _exit4:
 _exit3:
 	iounmap(attr.bar0);
 _exit2:
-	pci_release_regions(pdev);
+	pci_release_region(pdev, 0);
 _exit1:
 	pci_disable_device(pdev);
 _exit0:
@@ -4695,7 +4695,7 @@ static void __devexit vxge_remove(struct pci_dev *pdev)
 	vxge_hw_device_terminate(hldev);
 
 	pci_disable_device(pdev);
-	pci_release_regions(pdev);
+	pci_release_region(pdev, 0);
 	pci_set_drvdata(pdev, NULL);
 	vxge_debug_entryexit(vdev->level_trace,	"%s:%d  Exiting...", __func__,
 			     __LINE__);
-- 
1.7.0.4

