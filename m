From: Ondrej Zary <linux@rainbow-software.org>
Subject: 3c509 resume from hibernation broken somewhere between 2.6.25 and 2.6.28
Date: Fri, 6 Feb 2009 14:22:13 +0100
Message-ID: <200902061422.14746.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755622AbZBFNWc@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
last year, I posted a patch which fixed hibernation on 3c509 cards. That was 
back in 2.6.24. It worked fine in 2.6.25. But then I stopped using 
hibernation (as it did not work with my new IT8212 RAID controller).

Now I fixed it and noticed that 3c509 does not wake up properly anymore (in 
2.6.28) - neither in PnP nor in ISA modes. ifconfig down/up makes the card 
work again in PnP mode. However, in ISA mode, ifconfig up ends with "No such 
device" error.

Comparing the 3c509 driver between 2.6.25 and 2.6.28, there's only some 
statistics-related change. So the cause of the problem must be somewhere 
else.

This patch makes the resume work in PnP mode, but it's still not enough for 
ISA mode.

--- linux-2.6.28-orig/drivers/net/3c509.c	2009-01-02 17:19:07.000000000 +0100
+++ linux/drivers/net/3c509.c	2009-02-05 22:36:20.000000000 +0100
@@ -1477,6 +1477,7 @@
 	spin_lock_irqsave(&lp->lock, flags);
 
 	outw(PowerUp, ioaddr + EL3_CMD);
+	EL3WINDOW(0);
 	el3_up(dev);
 
 	if (netif_running(dev))

-- 
Ondrej Zary
