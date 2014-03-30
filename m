From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next] net/mlx4_core: Handle null return by pci_match_id()
Date: Sun, 30 Mar 2014 18:26:55 +0300
Message-ID: <1396193215-6863-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Wei Yang <weiyang@linux.vnet.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:54463 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751364AbaC3P1N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Mar 2014 11:27:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix issue introduced by commit: 97a5221 "net/mlx4_core: pass
pci_device_id.driver_data to __mlx4_init_one during reset".

pci_match_id() might return NULL if someone binds the driver to a device
manually using /sys/bus/pci/drivers/.../new_id. Need to check 'id'
before using it.

Thanks to Bjorn who raised the problem.

CC: Bjorn Helgaas <bhelgaas@google.com>
CC: Wei Yang <weiyang@linux.vnet.ibm.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index f0ae95f..a2f6623 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2759,6 +2759,9 @@ static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
 	int ret;
 
 	id = pci_match_id(mlx4_pci_table, pdev);
+	if (!id)
+		return PCI_ERS_RESULT_DISCONNECT;
+
 	ret = __mlx4_init_one(pdev, id->driver_data);
 
 	return ret ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
-- 
1.8.3.4
