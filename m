From: Anton Protopopov <a.s.protopopov@gmail.com>
Subject: [PATCH] ath10k: fix erroneous return value
Date: Wed, 10 Feb 2016 11:58:55 -0500
Message-ID: <1455123535-26751-1-git-send-email-a.s.protopopov@gmail.com>
Cc: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Anton Protopopov <a.s.protopopov@gmail.com>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ath10k_pci_hif_exchange_bmi_msg() function may return the positive
value EIO instead of -EIO in case of error.

Signed-off-by: Anton Protopopov <a.s.protopopov@gmail.com>
---
 drivers/net/wireless/ath/ath10k/pci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath10k/pci.c b/drivers/net/wireless/ath/ath10k/pci.c
index ee925c6..526acde 100644
--- a/drivers/net/wireless/ath/ath10k/pci.c
+++ b/drivers/net/wireless/ath/ath10k/pci.c
@@ -1756,7 +1756,7 @@ static int ath10k_pci_hif_exchange_bmi_msg(struct ath10k *ar,
 					    DMA_FROM_DEVICE);
 		ret = dma_mapping_error(ar->dev, resp_paddr);
 		if (ret) {
-			ret = EIO;
+			ret = -EIO;
 			goto err_req;
 		}
 
-- 
2.6.5
