From: Nigel Cunningham <nigel@nigel.suspend2.net>
Subject: Re: [RFC][PATCH] Add suspend and resume support to uli526x
Date: Tue, 05 Jun 2007 07:16:34 +1000
Message-ID: <1180991794.4356.31.camel@nigel.suspend2.net>
References: <200706031237.36773.rjw@sisk.pl>
	 <20070604111112.GP4363@elf.ucw.cz>  <200706041549.11277.rjw@sisk.pl>
Reply-To: nigel@nigel.suspend2.net
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-vfmw+hqBtflXcNcazV/5"
Cc: Pavel Machek <pavel@ucw.cz>, linux-pm <linux-pm@lists.osdl.org>,
	netdev@vger.kernel.org, Valerie Henson <val@nmt.edu>,
	Peer Chen <peer.chen@uli.com.tw>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nigel.suspend2.net ([203.171.70.205]:51157 "EHLO
	nigel.suspend2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760236AbXFDVQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 17:16:36 -0400
In-Reply-To: <200706041549.11277.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-vfmw+hqBtflXcNcazV/5
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi.

On Mon, 2007-06-04 at 15:49 +0200, Rafael J. Wysocki wrote:
> On Monday, 4 June 2007 13:11, Pavel Machek wrote:
> > > From: Rafael J. Wysocki <rjw@sisk.pl>
> > >=20
> > > Add suspend/resume support to the uli526x network driver (tested on x=
86_64,
> > > with 'Ethernet controller: ALi Corporation M5263 Ethernet Controller,=
 rev 40').
> > >=20
> > > Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> >=20
> > Looks ok to me.
> >=20
> > > +#ifdef CONFIG_PM
> > > +
> > > +/*
> > > + *	Suspend the interface.
> > > + */
> > > +
> > > +static int uli526x_suspend(struct pci_dev *pdev, pm_message_t state)
> > > +{
> > > +	struct net_device *dev =3D pci_get_drvdata(pdev);
> > > +
> > > +	ULI526X_DBUG(0, "uli526x_suspend", 0);
> > > +
> > > +	if (dev && netdev_priv(dev)) {
> > > +		if (netif_running(dev)) {
> > > +			netif_device_detach(dev);
> > > +			uli526x_down(dev);
> > > +		}
> > > +		pci_save_state(pdev);
> > > +		pci_enable_wake(pdev, pci_choose_state(pdev, state), 0);
> > > +		pci_disable_device(pdev);
> > > +		pci_set_power_state(pdev, pci_choose_state(pdev, state));
> > > +	}
> > > +	return 0;
> > > +}
> > > +
> > > +/*
> > > + *	Resume the interface.
> > > + */
> > > +
> > > +static int uli526x_resume(struct pci_dev *pdev)
> > > +{
> > > +	struct net_device *dev =3D pci_get_drvdata(pdev);
> > > +	struct uli526x_board_info *db =3D netdev_priv(dev);
> > > +	int err;
> > > +
> > > +	ULI526X_DBUG(0, "uli526x_resume", 0);
> > > +
> > > +	if (dev && db) {
> > > +		pci_set_power_state(pdev, PCI_D0);
> > > +		err =3D pci_enable_device(pdev);
> > > +		if (err) {
> > > +			printk(KERN_WARNING "%s: Could not enable device \n",
> > > +				dev->name);
> > > +			return err;
> > > +		}
> > > +		pci_restore_state(pdev);
> > > +		pci_set_master(pdev);
> > > +		if (netif_running(dev)) {
> > > +			uli526x_up(dev);
> > > +			netif_device_attach(dev);
> > > +		}
> > > +	}
> > > +	return 0;
> > > +}
> > > +
> > #else=20
> > #define *_resume NULL
> > #define *_suspend NULL
>=20
> > > +#endif /* CONFIG_PM */
> >=20
> > > @@ -1689,6 +1775,10 @@ static struct pci_driver uli526x_driver=20
> > >  	.id_table	=3D uli526x_pci_tbl,
> > >  	.probe		=3D uli526x_init_one,
> > >  	.remove		=3D __devexit_p(uli526x_remove_one),
> > > +#ifdef CONFIG_PM
> > > +	.suspend	=3D uli526x_suspend,
> > > +	.resume		=3D uli526x_resume,
> > > +#endif
> >=20
> > ...so that this ifdef is not needed?
>=20
> OK, why not.

Because it's uglier and #ifdef is the established way of doing things?

Regards,

Nigel

--=-vfmw+hqBtflXcNcazV/5
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGZIEyN0y+n1M3mo0RAlmZAKDzcDOO/bLt0SaHp5WRlIoMKFdBFwCgjDLR
AcsbO4e0Af/hBChdFFDRMDA=
=DkN5
-----END PGP SIGNATURE-----

--=-vfmw+hqBtflXcNcazV/5--

