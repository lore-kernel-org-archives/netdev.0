From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] atm: zatm: Fix an error handling path in 'zatm_init_one()'
Date: Mon, 17 Jul 2017 19:42:41 +0200
Message-ID: <20170717174241.18935-1-christophe.jaillet@wanadoo.fr>
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: 3chas3@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If 'dma_set_mask_and_coherent()' fails, we must undo the previous
'pci_request_regions()' call.
Adjust corresponding 'goto' to jump at the right place of the error
handling path.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/atm/zatm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/zatm.c b/drivers/atm/zatm.c
index 292dec18ffb8..07bdd51b3b9a 100644
--- a/drivers/atm/zatm.c
+++ b/drivers/atm/zatm.c
@@ -1613,7 +1613,7 @@ static int zatm_init_one(struct pci_dev *pci_dev,
 
 	ret = dma_set_mask_and_coherent(&pci_dev->dev, DMA_BIT_MASK(32));
 	if (ret < 0)
-		goto out_disable;
+		goto out_release;
 
 	zatm_dev->pci_dev = pci_dev;
 	dev->dev_data = zatm_dev;
-- 
2.11.0
