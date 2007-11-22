From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH] NET: dmfe: don't access configuration space in D3 state
Date: Fri, 23 Nov 2007 01:30:15 +0200
Message-ID: <200711230130.15939.maximlevitsky@gmail.com>
References: <200711230129.02570.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: LKML <linux-kernel@vger.kernel.org>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:60973 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbXKVXab convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 18:30:31 -0500
Received: by nf-out-0910.google.com with SMTP id g13so2585510nfb
        for <netdev@vger.kernel.org>; Thu, 22 Nov 2007 15:30:30 -0800 (PST)
In-Reply-To: <200711230129.02570.maximlevitsky@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From 7e24227257f315e52fe0b494dc1253d2a0ce5dff Mon Sep 17 00:00:00 2001
From: Maxim Levitsky <maximlevitsky@gmail.com>
Date: Fri, 23 Nov 2007 01:15:36 +0200
Subject: [PATCH] NET: dmfe: don't access configuration space in D3 state
 Accidently I reversed the order of pci_save_state and
 pci_set_power_state in .suspend()/.resume() callbacks

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
---
 drivers/net/tulip/dmfe.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 390d02d..9d199b0 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -2118,8 +2118,8 @@ static int dmfe_suspend(struct pci_dev *pci_dev, pm_message_t state)
 	pci_enable_wake(pci_dev, PCI_D3cold, 1);
 
 	/* Power down device*/
-	pci_set_power_state(pci_dev, pci_choose_state (pci_dev,state));
 	pci_save_state(pci_dev);
+	pci_set_power_state(pci_dev, pci_choose_state (pci_dev,state));
 
 	return 0;
 }
@@ -2129,8 +2129,8 @@ static int dmfe_resume(struct pci_dev *pci_dev)
 	struct net_device *dev = pci_get_drvdata(pci_dev);
 	u32 tmp;
 
-	pci_restore_state(pci_dev);
 	pci_set_power_state(pci_dev, PCI_D0);
+	pci_restore_state(pci_dev);
 
 	/* Re-initilize DM910X board */
 	dmfe_init_dm910x(dev);
-- 
1.5.3.4

