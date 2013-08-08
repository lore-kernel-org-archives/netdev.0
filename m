From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH 16/16] tg3: clean up unnecessary MSI/MSI-X capability find
Date: Thu, 8 Aug 2013 21:03:12 +0800
Message-ID: <1375966992-33236-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hanjun Guo <guohanjun@huawei.com>, <jiang.liu@huawei.com>,
	Yijing Wang <wangyijing@huawei.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PCI core will initialize device MSI/MSI-X capability in
pci_msi_init_pci_dev(). So device driver should use
pci_dev->msi_cap/msix_cap to determine whether the device
support MSI/MSI-X instead of using
pci_find_capability(pci_dev, PCI_CAP_ID_MSI/MSIX).
Access to PCIe device config space again will consume more time.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Cc: Nithin Nayak Sujir <nsujir@broadcom.com>
Cc: Michael Chan <mchan@broadcom.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/broadcom/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index ddebc7a..11cad77 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -15917,7 +15917,7 @@ static int tg3_get_invariants(struct tg3 *tp, const struct pci_device_id *ent)
 	 */
 	if (tg3_flag(tp, 5780_CLASS)) {
 		tg3_flag_set(tp, 40BIT_DMA_BUG);
-		tp->msi_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_MSI);
+		tp->msi_cap = tp->pdev->msi_cap;
 	} else {
 		struct pci_dev *bridge = NULL;
 
-- 
1.7.1
