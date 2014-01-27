From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net] bnx2x: More Shutdown revisions
Date: Mon, 27 Jan 2014 17:11:58 +0200
Message-ID: <1390835518-29652-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <yuvalmin@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:52294 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539AbaA0PMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 10:12:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Submission d9aee59 "bnx2x: Don't release PCI bars on shutdown" separated
the PCI remove and shutdown flows, but pci_disable_device() is still
being called on both.
As a result, a dev_WARN_ONCE will be hit during shutdown for every bnx2x
VF probed on a hypervisor (as its shutdown callback will be called and later
pci_disable_sriov() will call its remove callback).

This calls the pci_disable_device() only on the remove flow.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
Hi Dave,

Please consider applying this to `net' (or possibly net-next;
not sure exactly how things currently work).

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e118a3e..c9c445e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13102,9 +13102,9 @@ static void __bnx2x_remove(struct pci_dev *pdev,
 
 		if (atomic_read(&pdev->enable_cnt) == 1)
 			pci_release_regions(pdev);
-	}
 
-	pci_disable_device(pdev);
+		pci_disable_device(pdev);
+	}
 }
 
 static void bnx2x_remove_one(struct pci_dev *pdev)
-- 
1.8.1.227.g44fe835
