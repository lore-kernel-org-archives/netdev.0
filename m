From: Pan Bian <bianpan201602@163.com>
Subject: [PATCH 1/1] qlcnic: fix unchecked return value
Date: Sun, 23 Apr 2017 20:04:04 +0800
Message-ID: <1492949044-23580-1-git-send-email-bianpan201602@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Pan Bian <bianpan2016@163.com>
To: Harish Patil <harish.patil@cavium.com>,
        Manish Chopra <manish.chopra@cavium.com>,
        Dept-GELinuxNICDev@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pan Bian <bianpan2016@163.com>

Function pci_find_ext_capability() may return 0, which is an invalid
address. In function qlcnic_sriov_virtid_fn(), its return value is used
without validation. This may result in invalid memory access bugs. This
patch fixes the bug.

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index d710705..2f656f3 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -128,6 +128,8 @@ static int qlcnic_sriov_virtid_fn(struct qlcnic_adapter *adapter, int vf_id)
 		return 0;
 
 	pos = pci_find_ext_capability(dev, PCI_EXT_CAP_ID_SRIOV);
+	if (!pos)
+		return 0;
 	pci_read_config_word(dev, pos + PCI_SRIOV_VF_OFFSET, &offset);
 	pci_read_config_word(dev, pos + PCI_SRIOV_VF_STRIDE, &stride);
 
-- 
1.9.1
