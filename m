From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] ath10: mark PM functions as __maybe_unused
Date: Wed,  6 Sep 2017 14:58:53 +0200
Message-ID: <20170906125904.2588620-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Colin Ian King <colin.king@canonical.com>,
        Bartosz Markowski <bartosz.markowski@tieto.com>,
        Govind Singh <govinds@qti.qualcomm.com>,
        Ryan Hsu <ryanhsu@qti.qualcomm.com>,
        Srinivas Kandagatla <srinivas.kandagatla@linaro.org>,
        Rajkumar Manoharan <rmanohar@qti.qualcomm.com>,
        Ashok Raj Nagarajan <arnagara@qti.qualcomm.com>,
        Ben Greear <greearb@candelatech.com>,
        ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When CONFIG_PM_SLEEP is disabled, we get a compile-time
warning:

drivers/net/wireless/ath/ath10k/pci.c:3417:12: error: 'ath10k_pci_pm_resume' defined but not used [-Werror=unused-function]
 static int ath10k_pci_pm_resume(struct device *dev)
            ^~~~~~~~~~~~~~~~~~~~
drivers/net/wireless/ath/ath10k/pci.c:3401:12: error: 'ath10k_pci_pm_suspend' defined but not used [-Werror=unused-function]
 static int ath10k_pci_pm_suspend(struct device *dev)

Rather than fixing the #ifdef, this just marks both functions
as __maybe_unused, which is a more robust way to do this.

Fixes: 32faa3f0ee50 ("ath10k: add the PCI PM core suspend/resume ops")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/wireless/ath/ath10k/pci.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/pci.c b/drivers/net/wireless/ath/ath10k/pci.c
index bc1633945a56..195dafb98131 100644
--- a/drivers/net/wireless/ath/ath10k/pci.c
+++ b/drivers/net/wireless/ath/ath10k/pci.c
@@ -3396,9 +3396,7 @@ static void ath10k_pci_remove(struct pci_dev *pdev)
 
 MODULE_DEVICE_TABLE(pci, ath10k_pci_id_table);
 
-#ifdef CONFIG_PM
-
-static int ath10k_pci_pm_suspend(struct device *dev)
+static __maybe_unused int ath10k_pci_pm_suspend(struct device *dev)
 {
 	struct ath10k *ar = dev_get_drvdata(dev);
 	int ret;
@@ -3414,7 +3412,7 @@ static int ath10k_pci_pm_suspend(struct device *dev)
 	return ret;
 }
 
-static int ath10k_pci_pm_resume(struct device *dev)
+static __maybe_unused int ath10k_pci_pm_resume(struct device *dev)
 {
 	struct ath10k *ar = dev_get_drvdata(dev);
 	int ret;
@@ -3433,7 +3431,6 @@ static int ath10k_pci_pm_resume(struct device *dev)
 static SIMPLE_DEV_PM_OPS(ath10k_pci_pm_ops,
 			 ath10k_pci_pm_suspend,
 			 ath10k_pci_pm_resume);
-#endif
 
 static struct pci_driver ath10k_pci_driver = {
 	.name = "ath10k_pci",
-- 
2.9.0
