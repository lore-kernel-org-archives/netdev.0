From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 5/6] cxgb4: program pci completion timeout
Date: Fri,  5 Jun 2015 14:24:51 +0530
Message-ID: <1433494492-7638-6-git-send-email-hariprasad@chelsio.com>
References: <1433494492-7638-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:14009 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754014AbbFEDlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 23:41:49 -0400
In-Reply-To: <1433494492-7638-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set pci completion timeout to 0xd.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index da65e76..efd0aa1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -5847,6 +5847,22 @@ static int get_flash_params(struct adapter *adap)
 	return 0;
 }
 
+static void set_pcie_completion_timeout(struct adapter *adapter, u8 range)
+{
+	u16 val;
+	u32 pcie_cap;
+
+	pcie_cap = pci_find_capability(adapter->pdev, PCI_CAP_ID_EXP);
+	if (pcie_cap) {
+		pci_read_config_word(adapter->pdev,
+				     pcie_cap + PCI_EXP_DEVCTL2, &val);
+		val &= ~PCI_EXP_DEVCTL2_COMP_TIMEOUT;
+		val |= range;
+		pci_write_config_word(adapter->pdev,
+				      pcie_cap + PCI_EXP_DEVCTL2, val);
+	}
+}
+
 /**
  *	t4_prep_adapter - prepare SW and HW for operation
  *	@adapter: the adapter
@@ -5919,6 +5935,9 @@ int t4_prep_adapter(struct adapter *adapter)
 	adapter->params.nports = 1;
 	adapter->params.portvec = 1;
 	adapter->params.vpd.cclk = 50000;
+
+	/* Set pci completion timeout value to 4 seconds. */
+	set_pcie_completion_timeout(adapter, 0xd);
 	return 0;
 }
 
-- 
2.3.4
