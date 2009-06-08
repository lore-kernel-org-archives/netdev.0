From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: WoL and r8169
Date: Mon, 8 Jun 2009 23:53:01 +0200
Message-ID: <20090608215301.GA28044@electric-eye.fr.zoreil.com>
References: <20090607214220.5101B33C013@tippex.mynet.homeunix.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Anders Eriksson <aeriksson@fastmail.fm>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:51549 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754184AbZFHVvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 17:51:08 -0400
Content-Disposition: inline
In-Reply-To: <20090607214220.5101B33C013@tippex.mynet.homeunix.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anders Eriksson <aeriksson@fastmail.fm> :
[...]
> Any insight in the appreciated.

This one may be:

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 8247a94..8328f4d 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3817,14 +3817,6 @@ static int rtl8169_suspend(struct pci_dev *pdev, pm_message_t state)
 	netif_device_detach(dev);
 	netif_stop_queue(dev);
 
-	spin_lock_irq(&tp->lock);
-
-	rtl8169_asic_down(ioaddr);
-
-	rtl8169_rx_missed(dev, ioaddr);
-
-	spin_unlock_irq(&tp->lock);
-
 out_pci_suspend:
 	pci_save_state(pdev);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state),

-- 
Ueimor
