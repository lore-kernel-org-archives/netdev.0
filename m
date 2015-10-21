From: Punit Vara <punitvara@gmail.com>
Subject: [PATCH 01/15] net: wireless: ath: use | instead of + for summing bitmasks
Date: Wed, 21 Oct 2015 20:25:23 +0530
Message-ID: <1445439337-19055-2-git-send-email-punitvara@gmail.com>
References: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
Cc: stas.yakovlev@gmail.com, chaoming_li@realsil.com.cn,
	Larry.Finger@lwfinger.net, chunkeey@googlemail.com,
	sgruszka@redhat.com, brudley@broadcom.com, arend@broadcom.com,
	linville@tuxdriver.com, jirislaby@gmail.com, mickflemm@gmail.com,
	mcgrof@do-not-panic.com, k.eugene.e@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, wcn36xx@lists.infradead.org,
	johannes.berg@intel.com, meuleman@broadcom.com,
	Punit Vara <punitvara@gmail.com>
To: kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to the ath10k/pci.h file that fixes following warning
 reported by coccicheck:

WARNING: sum of probable bitmasks, consider |

I have replaced + with OR operator | for summing bitmasks

Signed-off-by: Punit Vara <punitvara@gmail.com>
---
 drivers/net/wireless/ath/ath10k/pci.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/pci.c b/drivers/net/wireless/ath/ath10k/pci.c
index 1046ab6..165a318 100644
--- a/drivers/net/wireless/ath/ath10k/pci.c
+++ b/drivers/net/wireless/ath/ath10k/pci.c
@@ -775,7 +775,7 @@ static u32 ath10k_pci_targ_cpu_to_ce_addr(struct ath10k *ar, u32 addr)
 	switch (ar->hw_rev) {
 	case ATH10K_HW_QCA988X:
 	case ATH10K_HW_QCA6174:
-		val = (ath10k_pci_read32(ar, SOC_CORE_BASE_ADDRESS +
+		val = (ath10k_pci_read32(ar, SOC_CORE_BASE_ADDRESS |
 					  CORE_CTRL_ADDRESS) &
 		       0x7ff) << 21;
 		break;
@@ -1443,10 +1443,10 @@ static void ath10k_pci_irq_msi_fw_mask(struct ath10k *ar)
 	switch (ar->hw_rev) {
 	case ATH10K_HW_QCA988X:
 	case ATH10K_HW_QCA6174:
-		val = ath10k_pci_read32(ar, SOC_CORE_BASE_ADDRESS +
+		val = ath10k_pci_read32(ar, SOC_CORE_BASE_ADDRESS |
 					CORE_CTRL_ADDRESS);
 		val &= ~CORE_CTRL_PCIE_REG_31_MASK;
-		ath10k_pci_write32(ar, SOC_CORE_BASE_ADDRESS +
+		ath10k_pci_write32(ar, SOC_CORE_BASE_ADDRESS |
 				   CORE_CTRL_ADDRESS, val);
 		break;
 	case ATH10K_HW_QCA99X0:
@@ -1464,10 +1464,10 @@ static void ath10k_pci_irq_msi_fw_unmask(struct ath10k *ar)
 	switch (ar->hw_rev) {
 	case ATH10K_HW_QCA988X:
 	case ATH10K_HW_QCA6174:
-		val = ath10k_pci_read32(ar, SOC_CORE_BASE_ADDRESS +
+		val = ath10k_pci_read32(ar, SOC_CORE_BASE_ADDRESS |
 					CORE_CTRL_ADDRESS);
 		val |= CORE_CTRL_PCIE_REG_31_MASK;
-		ath10k_pci_write32(ar, SOC_CORE_BASE_ADDRESS +
+		ath10k_pci_write32(ar, SOC_CORE_BASE_ADDRESS |
 				   CORE_CTRL_ADDRESS, val);
 		break;
 	case ATH10K_HW_QCA99X0:
-- 
2.5.3
