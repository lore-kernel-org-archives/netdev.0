From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: drivers/net: tulip_remove_one needs to call pci_disable_device()
Date: Fri, 14 Feb 2014 15:32:20 +0100
Message-ID: <1392388340-6527-1-git-send-email-bigeasy@linutronix.de>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:42331 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636AbaBNOcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 09:32:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>

Otherwise the device is not completely shut down.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
The patch is from "Date: Fri, 3 Jul 2009 08:30:18 -0500" and has been
in -RT since. Now that I stumbled upon it and didn't notice anything -RT
specific, here it comes.

diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index add05f1..1642de7 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -1939,6 +1939,7 @@ static void tulip_remove_one(struct pci_dev *pdev)
 	pci_iounmap(pdev, tp->base_addr);
 	free_netdev (dev);
 	pci_release_regions (pdev);
+	pci_disable_device(pdev);
 
 	/* pci_power_off (pdev, -1); */
 }
-- 
1.9.0.rc3
