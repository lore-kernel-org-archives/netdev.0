From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH 08/16] myri10ge: clean up unnecessary MSI/MSI-X capability find
Date: Thu, 8 Aug 2013 21:02:44 +0800
Message-ID: <1375966964-24156-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hanjun Guo <guohanjun@huawei.com>, <jiang.liu@huawei.com>,
	Yijing Wang <wangyijing@huawei.com>,
	Andrew Gallatin <gallatin@myri.com>, <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:41420 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964851Ab3HHNC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 09:02:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI core will initialize device MSI/MSI-X capability in
pci_msi_init_pci_dev(). So device driver should use
pci_dev->msi_cap/msix_cap to determine whether the device
support MSI/MSI-X instead of using
pci_find_capability(pci_dev, PCI_CAP_ID_MSI/MSIX).
Access to PCIe device config space again will consume more time.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Cc: Andrew Gallatin <gallatin@myri.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 967bae8..8772bb5 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -3625,13 +3625,12 @@ static void myri10ge_probe_slices(struct myri10ge_priv *mgp)
 	struct pci_dev *pdev = mgp->pdev;
 	char *old_fw;
 	bool old_allocated;
-	int i, status, ncpus, msix_cap;
+	int i, status, ncpus;
 
 	mgp->num_slices = 1;
-	msix_cap = pci_find_capability(pdev, PCI_CAP_ID_MSIX);
 	ncpus = netif_get_num_default_rss_queues();
 
-	if (myri10ge_max_slices == 1 || msix_cap == 0 ||
+	if (myri10ge_max_slices == 1 || !pdev->msix_cap ||
 	    (myri10ge_max_slices == -1 && ncpus < 2))
 		return;
 
-- 
1.7.1
