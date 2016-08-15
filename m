From: Colin King <colin.king@canonical.com>
Subject: [PATCH] ath10k: fix memory leak on caldata on error exit path
Date: Mon, 15 Aug 2016 14:46:25 +0100
Message-ID: <1471268785-11576-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>, ath10k@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

caldata is not being free'd on the error exit path, causing
a memory leak. kfree it to fix the leak.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/ath/ath10k/pci.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/ath/ath10k/pci.c b/drivers/net/wireless/ath/ath10k/pci.c
index 9a22c47..886337c 100644
--- a/drivers/net/wireless/ath/ath10k/pci.c
+++ b/drivers/net/wireless/ath/ath10k/pci.c
@@ -2725,6 +2725,7 @@ static int ath10k_pci_hif_fetch_cal_eeprom(struct ath10k *ar, void **data,
 	return 0;
 
 err_free:
+	kfree(caldata);
 	kfree(data);
 
 	return -EINVAL;
-- 
2.8.1
