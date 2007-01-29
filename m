From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH -FIX] e100: fix irq leak on suspend/resume
Date: Mon, 29 Jan 2007 14:31:16 -0800 (PST)
Message-ID: <20070129223116.1AB3F418CA@ahkok-mobl.jf.intel.com>
Cc: Frederik Deweerdt <frederik.deweerdt@gmail.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:41899 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932795AbXA2WbS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 17:31:18 -0500
Cc: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

e100: fix irq leak on suspend/resume

From: Frederik Deweerdt <frederik.deweerdt@gmail.com>

The e100_resume() function should be calling netif_device_detach and
free_irq. This fixes multiple irq's being allocated after resume.

Signed-off-by: Frederik Deweerdt <frederik.deweerdt@gmail.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index c2ae2a2..3208dac 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2725,6 +2725,7 @@ static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
 	del_timer_sync(&nic->watchdog);
 	netif_carrier_off(nic->netdev);
 
+	netif_device_detach(netdev);
 	pci_save_state(pdev);
 
 	if ((nic->flags & wol_magic) | e100_asf(nic)) {
@@ -2736,6 +2737,7 @@ static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
 	}
 
 	pci_disable_device(pdev);
+	free_irq(pdev->irq, netdev);
 	pci_set_power_state(pdev, PCI_D3hot);
 
 	return 0;
