From: =?iso-8859-1?b?RW1tYW51ZWwgRnVzdOk=?= <emmanuel.fuste@laposte.net>
Subject: Re: [PCNET32] Lock solid with netconsole
Date: Mon, 28 May 2007 00:41:35 +0200
Message-ID: <JIQ1PB$BBCF1554D3E697155C981E9F1E1E066A@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "tsbogend" <tsbogend@alpha.franken.de>,
	"pcnet32" <pcnet32@verizon.net>, "netdev" <netdev@vger.kernel.org>
To: "romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.laposte.net ([81.255.54.16]:61121 "EHLO mx.laposte.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418AbXE0Wls convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 18:41:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ok will try and report the result.
Thanks.
> Emmanuel Fust=E9 <emmanuel.fuste@laposte.net> :
> [...]
> > Just to let you know that I swap my pcnet32 with a via-rhine
> > and I no longer experienced hard machine lock after loading
> > netconsole.
>=20
> Any difference if you disable the debug messages in the pcnet32
> driver and you apply the patch below ?
>=20
> diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
> index 9c171a7..be4513f 100644
> --- a/drivers/net/pcnet32.c
> +++ b/drivers/net/pcnet32.c
> @@ -2556,11 +2556,12 @@ pcnet32_interrupt(int irq, void *dev_id)
>  	unsigned long ioaddr;
>  	u16 csr0;
>  	int boguscnt =3D max_interrupt_work;
> +	unsigned long flags;
> =20
>  	ioaddr =3D dev->base_addr;
>  	lp =3D netdev_priv(dev);
> =20
> -	spin_lock(&lp->lock);
> +	spin_lock_irqsave(&lp->lock, flags);
> =20
>  	csr0 =3D lp->a.read_csr(ioaddr, CSR0);
>  	while ((csr0 & 0x8f00) && --boguscnt >=3D 0) {
> @@ -2632,7 +2633,7 @@ pcnet32_interrupt(int irq, void *dev_id)
>  		printk(KERN_DEBUG "%s: exiting interrupt, csr0=3D%#4.4x.\n",
>  		       dev->name, lp->a.read_csr(ioaddr, CSR0));
> =20
> -	spin_unlock(&lp->lock);
> +	spin_unlock_irqrestore(&lp->lock, flags);
> =20
>  	return IRQ_HANDLED;
>  }
>=20

---

Cr=E9ez votre adresse =E9lectronique prenom.nom@laposte.net=20
1 Go d'espace de stockage, anti-spam et anti-virus int=E9gr=E9s.

