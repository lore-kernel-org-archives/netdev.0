From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 10/10] atl1c: add flag of PCI_DEV_FLAGS_MSI_INTX_DISABLE_BUG
Date: Thu, 26 Apr 2012 14:41:01 +0800
Message-ID: <1335422461-16588-3-git-send-email-xiong@qca.qualcomm.com>
References: <1335422461-16588-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:52442 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634Ab2DZGmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 02:42:13 -0400
In-Reply-To: <1335422461-16588-1-git-send-email-xiong@qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

supported devices all have one issue that msi interrupt doesn't assert
if pci command register bit (PCI_COMMAND_INTX_DISABLE) is set.
that bit should be effect only for INTx style interrupt.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 25b7b00..07b6018 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2434,6 +2434,7 @@ static int __devinit atl1c_probe(struct pci_dev *pdev,
 		dev_err(&pdev->dev, "cannot map device registers\n");
 		goto err_ioremap;
 	}
+	pdev->dev_flags |= PCI_DEV_FLAGS_MSI_INTX_DISABLE_BUG;
 
 	/* init mii data */
 	adapter->mii.dev = netdev;
-- 
1.7.7
