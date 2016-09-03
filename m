From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] ath10k: fix memory leak on caldata on error exit path
Date: Sat,  3 Sep 2016 17:38:19 +0100
Message-ID: <20160903163819.13115-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>, ath10k@lists.infradead.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

caldata is not being free'd on the error exit path, causing
a memory leak and data definitely should not be freed. Free
caldata instead of data.

Thanks to Kalle Valo for spotting that data should not be
free'd.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/ath/ath10k/pci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath10k/pci.c b/drivers/net/wireless/ath/ath10k/pci.c
index 9a22c47..afdf0fa 100644
--- a/drivers/net/wireless/ath/ath10k/pci.c
+++ b/drivers/net/wireless/ath/ath10k/pci.c
@@ -2725,7 +2725,7 @@ static int ath10k_pci_hif_fetch_cal_eeprom(struct ath10k *ar, void **data,
 	return 0;
 
 err_free:
-	kfree(data);
+	kfree(caldata);
 
 	return -EINVAL;
 }
-- 
2.9.3
