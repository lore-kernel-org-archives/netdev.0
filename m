From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH net-next 03/35] tg3: Use pci_enable_msix_range() instead of pci_enable_msix()
Date: Tue, 18 Feb 2014 11:07:55 +0100
Message-ID: <0a7f2b8a12cdd300aa3e2ec2649e3e401381181c.1392717502.git.agordeev@redhat.com>
References: <cover.1392717502.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392717502.git.agordeev@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As result of deprecation of MSI-X/MSI enablement functions
pci_enable_msix() and pci_enable_msi_block() all drivers
using these two interfaces need to be updated to use the
new pci_enable_msi_range() and pci_enable_msix_range()
interfaces.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
Cc: Nithin Nayak Sujir <nsujir@broadcom.com>
Cc: Michael Chan <mchan@broadcom.com>
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org
---
 drivers/net/ethernet/broadcom/tg3.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3167ed6..6e5e7c0 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -11362,12 +11362,10 @@ static bool tg3_enable_msix(struct tg3 *tp)
 		msix_ent[i].vector = 0;
 	}
 
-	rc = pci_enable_msix(tp->pdev, msix_ent, tp->irq_cnt);
+	rc = pci_enable_msix_range(tp->pdev, msix_ent, 1, tp->irq_cnt);
 	if (rc < 0) {
 		return false;
-	} else if (rc != 0) {
-		if (pci_enable_msix(tp->pdev, msix_ent, rc))
-			return false;
+	} else if (rc < tp->irq_cnt) {
 		netdev_notice(tp->dev, "Requested %d MSI-X vectors, received %d\n",
 			      tp->irq_cnt, rc);
 		tp->irq_cnt = rc;
-- 
1.7.7.6
