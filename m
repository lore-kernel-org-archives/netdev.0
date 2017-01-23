From: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>
Subject: [PATCH 3/3] ath10k: fix typo in addr calculation
Date: Mon, 23 Jan 2017 15:04:36 +0000
Message-ID: <1485183876-27080-3-git-send-email-srinivas.kandagatla@linaro.org>
References: <1485183876-27080-1-git-send-email-srinivas.kandagatla@linaro.org>
Cc: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Srinivas Kandagatla <srinivas.kandagatla@linaro.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485183876-27080-1-git-send-email-srinivas.kandagatla@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CORE_CTRL_ADDRESS is offset in register address space, it does not
make sense to OR it to derive the final address. It looks like its
a typo, so fix it.
Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>
---
 drivers/net/wireless/ath/ath10k/pci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath10k/pci.c b/drivers/net/wireless/ath/ath10k/pci.c
index 855e3de..023ab10 100644
--- a/drivers/net/wireless/ath/ath10k/pci.c
+++ b/drivers/net/wireless/ath/ath10k/pci.c
@@ -1936,7 +1936,7 @@ static int ath10k_pci_wake_target_cpu(struct ath10k *ar)
 {
 	u32 addr, val;
 
-	addr = SOC_CORE_BASE_ADDRESS | CORE_CTRL_ADDRESS;
+	addr = SOC_CORE_BASE_ADDRESS + CORE_CTRL_ADDRESS;
 	val = ath10k_pci_read32(ar, addr);
 	val |= CORE_CTRL_CPU_INTR_MASK;
 	ath10k_pci_write32(ar, addr, val);
-- 
2.10.1
