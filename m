From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 10/11] tlan: Enable device at resume
Date: Sat, 21 Jun 2014 16:47:55 +0200
Message-ID: <1403362076-7777-11-git-send-email-linux@rainbow-software.org>
References: <1403362076-7777-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403362076-7777-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pci_disable_device() is called in _suspend but there's no corresponding
pci_enable_device() in _resume.
This causes "disabling already-disabled device" warning on 2nd suspend.

Add pci_enable_device() call to _resume to fix this problem.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/ti/tlan.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index ef32e5f..3c88ac2 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -366,8 +366,10 @@ static int tlan_suspend(struct pci_dev *pdev, pm_message_t state)
 static int tlan_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
+	int rc = pci_enable_device(pdev);
 
-	pci_set_power_state(pdev, PCI_D0);
+	if (rc)
+		return rc;
 	pci_restore_state(pdev);
 	pci_enable_wake(pdev, PCI_D0, 0);
 	netif_device_attach(dev);
-- 
Ondrej Zary
