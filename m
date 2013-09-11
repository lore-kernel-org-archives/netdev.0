From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH] alx: remove redundant D0 power state set
Date: Wed, 11 Sep 2013 10:07:00 +0800
Message-ID: <1378865220-9368-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Yijing Wang <wangyijing@huawei.com>,
	Hanjun Guo <guohanjun@huawei.com>
To: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:54707 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266Ab3IKCIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 22:08:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pci_enable_device_mem() will set device power state to D0,
so it's no need to do it again in alx_probe().
Also remove redundant PM Cap find code, because pci core
has been saved the pci device pm cap value.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/net/ethernet/atheros/alx/main.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 027398e..fc95b23 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -1188,7 +1188,7 @@ static int alx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct alx_priv *alx;
 	struct alx_hw *hw;
 	bool phy_configured;
-	int bars, pm_cap, err;
+	int bars, err;
 
 	err = pci_enable_device_mem(pdev);
 	if (err)
@@ -1225,18 +1225,13 @@ static int alx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pci_enable_pcie_error_reporting(pdev);
 	pci_set_master(pdev);
 
-	pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
-	if (pm_cap == 0) {
+	if (!pdev->pm_cap) {
 		dev_err(&pdev->dev,
 			"Can't find power management capability, aborting\n");
 		err = -EIO;
 		goto out_pci_release;
 	}
 
-	err = pci_set_power_state(pdev, PCI_D0);
-	if (err)
-		goto out_pci_release;
-
 	netdev = alloc_etherdev(sizeof(*alx));
 	if (!netdev) {
 		err = -ENOMEM;
-- 
1.7.1
