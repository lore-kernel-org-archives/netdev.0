From: Joe Perches <joe@perches.com>
Subject: [PATCH 14/22] irda: Use pci_zalloc_consistent
Date: Mon, 23 Jun 2014 06:41:42 -0700
Message-ID: <fe9eb5f7868e6f7967b0ccd22d9d8550a990a46a.1403530604.git.joe@perches.com>
References: <cover.1403530604.git.joe@perches.com>
Cc: Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1403530604.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the now unnecessary memset too.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/irda/vlsi_ir.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index 4850066..58ef594 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -485,13 +485,13 @@ static int vlsi_create_hwif(vlsi_irda_dev_t *idev)
 	idev->virtaddr = NULL;
 	idev->busaddr = 0;
 
-	ringarea = pci_alloc_consistent(idev->pdev, HW_RING_AREA_SIZE, &idev->busaddr);
+	ringarea = pci_zalloc_consistent(idev->pdev, HW_RING_AREA_SIZE,
+					 &idev->busaddr);
 	if (!ringarea) {
 		IRDA_ERROR("%s: insufficient memory for descriptor rings\n",
 			   __func__);
 		goto out;
 	}
-	memset(ringarea, 0, HW_RING_AREA_SIZE);
 
 	hwmap = (struct ring_descr_hw *)ringarea;
 	idev->rx_ring = vlsi_alloc_ring(idev->pdev, hwmap, ringsize[1],
-- 
1.8.1.2.459.gbcd45b4.dirty
