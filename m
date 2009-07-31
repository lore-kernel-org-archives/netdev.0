From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2/2 net-next-2.6] cxgb3: fix Gen2 pci default settings
Date: Fri, 31 Jul 2009 00:23:39 -0700
Message-ID: <20090731072339.4325.23090.stgit@speedy5>
References: <20090731072334.4325.34323.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:2942 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752790AbZGaHXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2009 03:23:40 -0400
In-Reply-To: <20090731072334.4325.34323.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Modify control register settings to accommodate the bridge's max read requset
size.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/t3_hw.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)


diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index e78d341..526e144 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -3465,7 +3465,7 @@ static void config_pcie(struct adapter *adap)
 		{201, 321, 258, 450, 834, 1602}
 	};
 
-	u16 val;
+	u16 val, devid;
 	unsigned int log2_width, pldsize;
 	unsigned int fst_trn_rx, fst_trn_tx, acklat, rpllmt;
 
@@ -3473,6 +3473,17 @@ static void config_pcie(struct adapter *adap)
 			     adap->params.pci.pcie_cap_addr + PCI_EXP_DEVCTL,
 			     &val);
 	pldsize = (val & PCI_EXP_DEVCTL_PAYLOAD) >> 5;
+
+	pci_read_config_word(adap->pdev, 0x2, &devid);
+	if (devid == 0x37) {
+		pci_write_config_word(adap->pdev,
+				      adap->params.pci.pcie_cap_addr +
+				      PCI_EXP_DEVCTL,
+				      val & ~PCI_EXP_DEVCTL_READRQ &
+				      ~PCI_EXP_DEVCTL_PAYLOAD);
+		pldsize = 0;
+	}
+
 	pci_read_config_word(adap->pdev,
 			     adap->params.pci.pcie_cap_addr + PCI_EXP_LNKCTL,
 			     &val);

