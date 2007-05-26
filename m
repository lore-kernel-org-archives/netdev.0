From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PCNET32] Lock solid with netconsole
Date: Sun, 27 May 2007 00:41:20 +0200
Message-ID: <20070526224120.GA4476@electric-eye.fr.zoreil.com>
References: <JIO5LO$C60EE63CB5A48D2316D385244D1DAE4C@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tsbogend <tsbogend@alpha.franken.de>,
	pcnet32 <pcnet32@verizon.net>, netdev <netdev@vger.kernel.org>
To: Emmanuel =?iso-8859-1?Q?Fust=E9?= <emmanuel.fuste@laposte.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:49914 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750800AbXEZWnq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 May 2007 18:43:46 -0400
Content-Disposition: inline
In-Reply-To: <JIO5LO$C60EE63CB5A48D2316D385244D1DAE4C@laposte.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Emmanuel Fust=E9 <emmanuel.fuste@laposte.net> :
[...]
> Just to let you know that I swap my pcnet32 with a via-rhine
> and I no longer experienced hard machine lock after loading
> netconsole.

Any difference if you disable the debug messages in the pcnet32
driver and you apply the patch below ?

diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 9c171a7..be4513f 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -2556,11 +2556,12 @@ pcnet32_interrupt(int irq, void *dev_id)
 	unsigned long ioaddr;
 	u16 csr0;
 	int boguscnt =3D max_interrupt_work;
+	unsigned long flags;
=20
 	ioaddr =3D dev->base_addr;
 	lp =3D netdev_priv(dev);
=20
-	spin_lock(&lp->lock);
+	spin_lock_irqsave(&lp->lock, flags);
=20
 	csr0 =3D lp->a.read_csr(ioaddr, CSR0);
 	while ((csr0 & 0x8f00) && --boguscnt >=3D 0) {
@@ -2632,7 +2633,7 @@ pcnet32_interrupt(int irq, void *dev_id)
 		printk(KERN_DEBUG "%s: exiting interrupt, csr0=3D%#4.4x.\n",
 		       dev->name, lp->a.read_csr(ioaddr, CSR0));
=20
-	spin_unlock(&lp->lock);
+	spin_unlock_irqrestore(&lp->lock, flags);
=20
 	return IRQ_HANDLED;
 }
