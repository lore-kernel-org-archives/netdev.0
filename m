From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 23/26] can: c_can_pci: enable PCI bus master only for MSI
Date: Fri, 25 Apr 2014 00:00:26 +0200
Message-ID: <1398376829-6771-24-git-send-email-mkl@pengutronix.de>
References: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wolfgang Grandegger <wg@grandegger.com>

Coverity complains that c_can_pci_probe() calls pci_enable_msi() without
checking the result:

CID 712278 (#1 of 1): Unchecked return value (CHECKED_RETURN) 3. check_return:
Calling pci_enable_msi_block without checking return value (as is done
elsewhere 88 out of 105 times).
 88        pci_enable_msi(pdev);

This is CID 712278.

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
Reported-by: Bjorn Helgaas <bhelgaas@google.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can_pci.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/c_can/c_can_pci.c b/drivers/net/can/c_can/c_can_pci.c
index 1b7ff40..fe5f630 100644
--- a/drivers/net/can/c_can/c_can_pci.c
+++ b/drivers/net/can/c_can/c_can_pci.c
@@ -84,8 +84,11 @@ static int c_can_pci_probe(struct pci_dev *pdev,
 		goto out_disable_device;
 	}
 
-	pci_set_master(pdev);
-	pci_enable_msi(pdev);
+	ret = pci_enable_msi(pdev);
+	if (!ret) {
+		dev_info(&pdev->dev, "MSI enabled\n");
+		pci_set_master(pdev);
+	}
 
 	addr = pci_iomap(pdev, 0, pci_resource_len(pdev, 0));
 	if (!addr) {
-- 
1.9.0.279.gdc9e3eb

