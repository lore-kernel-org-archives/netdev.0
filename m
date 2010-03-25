From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv1 3/4] netxen: added sanity check for pci map
Date: Thu, 25 Mar 2010 00:06:45 -0700
Message-ID: <1269500806-15383-4-git-send-email-amit.salecha@qlogic.com>
References: <1269500806-15383-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:1655 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753011Ab0CYHGs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Mar 2010 03:06:48 -0400
In-Reply-To: <1269500806-15383-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Return value of ioremap is not checked, NULL check added.
---
 drivers/net/netxen/netxen_nic_main.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 9a7a0f3..cf06a51 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -636,10 +636,24 @@ netxen_setup_pci_map(struct netxen_adapter *adapter)
 		mem_ptr2 = ioremap(mem_base + THIRD_PAGE_GROUP_START,
 				THIRD_PAGE_GROUP_SIZE);
 		pci_len0 = FIRST_PAGE_GROUP_SIZE;
+
+		if (mem_ptr0 == NULL || mem_ptr1 == NULL || mem_ptr2 == NULL) {
+			dev_err(&pdev->dev, "failed to map PCI bar 0\n");
+			err = -EIO;
+			goto err_out;
+		}
+
 	} else if (mem_len == NETXEN_PCI_32MB_SIZE) {
 		mem_ptr1 = ioremap(mem_base, SECOND_PAGE_GROUP_SIZE);
 		mem_ptr2 = ioremap(mem_base + THIRD_PAGE_GROUP_START -
 			SECOND_PAGE_GROUP_START, THIRD_PAGE_GROUP_SIZE);
+
+		if (mem_ptr1 == NULL || mem_ptr2 == NULL) {
+			dev_err(&pdev->dev, "failed to map PCI bar 0\n");
+			err = -EIO;
+			goto err_out;
+		}
+
 	} else if (mem_len == NETXEN_PCI_2MB_SIZE) {
 
 		mem_ptr0 = pci_ioremap_bar(pdev, 0);
-- 
1.6.0.2

