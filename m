From: Matthew Garrett <mjg@redhat.com>
Subject: [PATCH V2 2/6] net/ethernet/atl1e: Disable ASPM
Date: Fri, 11 Nov 2011 11:14:20 -0500
Message-ID: <1321028064-644-3-git-send-email-mjg@redhat.com>
References: <1321028064-644-1-git-send-email-mjg@redhat.com>
Cc: Matthew Garrett <mjg@redhat.com>, netdev@vger.kernel.org,
	jcliburn@gmail.com, chris.snook@gmail.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321028064-644-1-git-send-email-mjg@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

http://www.atheros.cz/atheros-inf-file.php?inf=209&chipset=45&system=6
indicates that ASPM is disabled on all L1E hardware. Duplicate for sanity.

Signed-off-by: Matthew Garrett <mjg@redhat.com>
Cc: netdev@vger.kernel.org
Cc: jcliburn@gmail.com
Cc: chris.snook@gmail.com
---
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 95483bc..fc74dd1 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -2264,6 +2264,9 @@ static int __devinit atl1e_probe(struct pci_dev *pdev,
 
 	int err = 0;
 
+	pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S | PCIE_LINK_STATE_L1 |
+			       PCIE_LINK_STATE_CLKPM);
+
 	err = pci_enable_device(pdev);
 	if (err) {
 		dev_err(&pdev->dev, "cannot enable PCI device\n");
-- 
1.7.7.1
