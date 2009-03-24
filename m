From: Karsten Wiese <fzu@wemgehoertderstaat.de>
Subject: Re: [PATCH] r8169: Fix irq masking in rtl8169_interrupt()
Date: Tue, 24 Mar 2009 01:38:32 +0100
Message-ID: <200903240138.32805.fzu@wemgehoertderstaat.de>
References: <200903172034.55241.fzu@wemgehoertderstaat.de> <200903230053.29125.fzu@wemgehoertderstaat.de> <20090323224222.GA18951@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Rafael Wysocki <rjw@sisk.pl>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout3.freenet.de ([195.4.92.93]:39539 "EHLO mout3.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753335AbZCXAjc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 20:39:32 -0400
In-Reply-To: <20090323224222.GA18951@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag 23 M=E4rz 2009 schrieb Francois Romieu:
> Karsten Wiese <fzu@wemgehoertderstaat.de> :
> [...]
> > Yes, deavtivated in BIOS.
>=20
> Ok, it starts to make some sense.
>=20
> Does the patch below make a difference ?

No.

> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 4b7cb38..b5a7358 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -2011,8 +2011,6 @@ rtl8169_init_one(struct pci_dev *pdev, const st=
ruct pci_device_id *ent)
>  		}
>  	}
> =20
> -	pci_set_master(pdev);
> -
>  	/* ioremap MMIO region */
>  	ioaddr =3D ioremap(pci_resource_start(pdev, region), R8169_REGS_SIZ=
E);
>  	if (!ioaddr) {
> @@ -2039,6 +2037,8 @@ rtl8169_init_one(struct pci_dev *pdev, const st=
ruct pci_device_id *ent)
>  		msleep_interruptible(1);
>  	}
> =20
> +	pci_set_master(pdev);
> +
>  	/* Identify chip attached to board */
>  	rtl8169_get_mac_version(tp, ioaddr);
> =20

