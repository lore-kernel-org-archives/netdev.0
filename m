From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net] PCI: fix the return value for the pci_find_pcie_root_port()
Date: Thu, 17 Aug 2017 10:25:30 +0800
Message-ID: <1502936730-7368-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ding Tianhong <dingtianhong@huawei.com>,
        Thierry Reding <thierry.reding@gmail.com>
To: <leedom@chelsio.com>, <ashok.raj@intel.com>, <bhelgaas@google.com>,
        <helgaas@kernel.org>, <werner@chelsio.com>, <ganeshgr@chelsio.com>,
        <asit.k.mallick@intel.com>, <patrick.j.cramer@intel.com>,
        <Suravee.Suthikulpanit@amd.com>, <Bob.Shaw@amd.com>,
        <l.stach@pengutronix.de>, <amira@mellanox.com>,
        <gabriele.paoloni@huawei.com>, <David.Laight@aculab.com>,
        <jeffrey.t.kirsher@intel.com>, <catalin.marinas@arm.com>,
        <will.deacon@arm.com>, <mark.rutland@arm.com>,
        <robin.murphy@arm.com>, <davem@davemloft.net>,
        <alexander.duyck@gmail.com>, <eric.dumazet@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:3574 "EHLO
        szxga05-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751943AbdHQC0N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 22:26:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pci_find_pcie_root_port() would return NULL if the given
dev is already a Root Port, it looks like unfriendly to the
PCIe Root Port device, Thierry and Bjorn suggest to let this
function return the given dev under this circumstances.

Fixes: 0e405232871d6 ("PCI: fix oops when try to find Root Port for a PCI device")
Suggested-by: Thierry Reding <thierry.reding@gmail.com>
Suggested-by: Bjorn Helgaas <helgaas@kernel.org>
Signed-off-by: Thierry Reding <thierry.reding@gmail.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/pci/pci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index 7e2022f..352bb53 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -514,7 +514,7 @@ struct resource *pci_find_resource(struct pci_dev *dev, struct resource *res)
  */
 struct pci_dev *pci_find_pcie_root_port(struct pci_dev *dev)
 {
-	struct pci_dev *bridge, *highest_pcie_bridge = NULL;
+	struct pci_dev *bridge, *highest_pcie_bridge = dev;
 
 	bridge = pci_upstream_bridge(dev);
 	while (bridge && pci_is_pcie(bridge)) {
-- 
1.8.3.1
