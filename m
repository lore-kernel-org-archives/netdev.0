From: Steven Walter <stevenrwalter@gmail.com>
Subject: [PATCH 1/2] tulip: explicity set to D0 power state during init
Date: Mon, 31 May 2010 18:34:42 -0400
Message-ID: <1275345283-10650-1-git-send-email-stevenrwalter@gmail.com>
Cc: Steven Walter <stevenrwalter@gmail.com>
To: grundler@parisc-linux.org, kyle@mcmartin.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.211.179]:61464 "EHLO
	mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752735Ab0EaWe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 18:34:58 -0400
Received: by ywh9 with SMTP id 9so2999221ywh.17
        for <netdev@vger.kernel.org>; Mon, 31 May 2010 15:34:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During the first suspend the chip would refuse to enter D3.  Subsequent
suspends worked okay.  During resume the chip is commanded into D0.
Doing so during initialization fixes the initial suspend.

Signed-off-by: Steven Walter <stevenrwalter@gmail.com>
---
 drivers/net/tulip/tulip_core.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 3810db9..bb8c0ee 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1380,6 +1380,13 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 		return i;
 	}
 
+	/* The chip will fail to enter a low-power state later unless
+	 * first explicitly commanded into D0 */
+	if (pci_set_power_state(pdev, PCI_D0)) {
+		printk (KERN_ERR PFX
+			"Failed to set power state to D0\n");
+	}
+
 	irq = pdev->irq;
 
 	/* alloc_etherdev ensures aligned and zeroed private structures */
-- 
1.6.3.3

