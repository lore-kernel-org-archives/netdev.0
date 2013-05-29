From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH] tg3: remove redundant pm init code
Date: Wed, 29 May 2013 17:00:32 +0800
Message-ID: <1369818032-36272-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, Hanjun Guo <guohanjun@huawei.com>,
	Jiang Liu <liuj97@gmail.com>,
	Yijing Wang <wangyijing@huawei.com>
To: Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pci_enable_device() will set device pm state to D0, so
it's no need to do it again in tg3_init_one().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   20 +-------------------
 1 files changed, 1 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 728d42a..1396ab3 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17042,25 +17042,10 @@ static int tg3_init_one(struct pci_dev *pdev,
 
 	pci_set_master(pdev);
 
-	/* Find power-management capability. */
-	pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
-	if (pm_cap == 0) {
-		dev_err(&pdev->dev,
-			"Cannot find Power Management capability, aborting\n");
-		err = -EIO;
-		goto err_out_free_res;
-	}
-
-	err = pci_set_power_state(pdev, PCI_D0);
-	if (err) {
-		dev_err(&pdev->dev, "Transition to D0 failed, aborting\n");
-		goto err_out_free_res;
-	}
-
 	dev = alloc_etherdev_mq(sizeof(*tp), TG3_IRQ_MAX_VECS);
 	if (!dev) {
 		err = -ENOMEM;
-		goto err_out_power_down;
+		goto err_out_free_res;
 	}
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
@@ -17406,9 +17391,6 @@ err_out_iounmap:
 err_out_free_dev:
 	free_netdev(dev);
 
-err_out_power_down:
-	pci_set_power_state(pdev, PCI_D3hot);
-
 err_out_free_res:
 	pci_release_regions(pdev);
 
-- 
1.7.1
