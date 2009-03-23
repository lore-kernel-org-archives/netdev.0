From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Fix irq masking in rtl8169_interrupt()
Date: Mon, 23 Mar 2009 23:42:22 +0100
Message-ID: <20090323224222.GA18951@electric-eye.fr.zoreil.com>
References: <200903172034.55241.fzu@wemgehoertderstaat.de> <200903200240.50183.fzu@wemgehoertderstaat.de> <20090322211629.GA23095@electric-eye.fr.zoreil.com> <200903230053.29125.fzu@wemgehoertderstaat.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Rafael Wysocki <rjw@sisk.pl>
To: Karsten Wiese <fzu@wemgehoertderstaat.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58389 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751408AbZCWWjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 18:39:01 -0400
Content-Disposition: inline
In-Reply-To: <200903230053.29125.fzu@wemgehoertderstaat.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karsten Wiese <fzu@wemgehoertderstaat.de> :
[...]
> Yes, deavtivated in BIOS.

Ok, it starts to make some sense.

Does the patch below make a difference ?

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 4b7cb38..b5a7358 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2011,8 +2011,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		}
 	}
 
-	pci_set_master(pdev);
-
 	/* ioremap MMIO region */
 	ioaddr = ioremap(pci_resource_start(pdev, region), R8169_REGS_SIZE);
 	if (!ioaddr) {
@@ -2039,6 +2037,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		msleep_interruptible(1);
 	}
 
+	pci_set_master(pdev);
+
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, ioaddr);
 
-- 
Ueimor

