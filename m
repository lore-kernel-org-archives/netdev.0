From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCHv2] netxen: fix pci bar mapping
Date: Sun, 11 Oct 2009 23:13:51 -0700
Message-ID: <1255328031-17189-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:50636 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753768AbZJLGO1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Oct 2009 02:14:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use phys_addr_t data type for pci resource address
instead of unsigned long. This fixes mapping of
pci resources where resource addresses can be larger
than word size (e.g. PAE).

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 9b9eab1..7fc15e9 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -595,7 +595,8 @@ netxen_setup_pci_map(struct netxen_adapter *adapter)
 	void __iomem *mem_ptr2 = NULL;
 	void __iomem *db_ptr = NULL;
 
-	unsigned long mem_base, mem_len, db_base, db_len = 0, pci_len0 = 0;
+	resource_size_t mem_base, db_base;
+	unsigned long mem_len, db_len = 0, pci_len0 = 0;
 
 	struct pci_dev *pdev = adapter->pdev;
 	int pci_func = adapter->ahw.pci_func;
-- 
1.6.0.2

