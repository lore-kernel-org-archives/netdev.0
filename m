From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH 7/7] tulip: remove redundant D0 power state set
Date: Thu, 30 May 2013 18:27:06 +0800
Message-ID: <1369909626-37832-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Hanjun Guo <guohanjun@huawei.com>,
	Jiang Liu <liuj97@gmail.com>,
	Yijing Wang <wangyijing@huawei.com>
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:38994 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968055Ab3E3K1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 06:27:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pci_enable_device() will set device power state to D0,
so it's no need to do it again in tulip_init_one().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/net/ethernet/dec/tulip/tulip_core.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 1e9443d..c94152f 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -1410,12 +1410,6 @@ static int tulip_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		return i;
 	}
 
-	/* The chip will fail to enter a low-power state later unless
-	 * first explicitly commanded into D0 */
-	if (pci_set_power_state(pdev, PCI_D0)) {
-		pr_notice("Failed to set power state to D0\n");
-	}
-
 	irq = pdev->irq;
 
 	/* alloc_etherdev ensures aligned and zeroed private structures */
-- 
1.7.1
