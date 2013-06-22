From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 1/1] alx: add a simple AR816x/AR817x device driver
Date: Sat, 22 Jun 2013 15:21:51 +0100
Message-ID: <1371910911.8771.53.camel@deadeye.wl.decadent.org.uk>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <1370899746-14219-1-git-send-email-johannes@sipsolutions.net>
	 <1371518286.3495.60.camel@deadeye.wl.decadent.org.uk>
	 <1371764438.8333.20.camel@jlt4.sipsolutions.net>
	 <20130622101758.GA5427@sig21.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-FmH4EmV2+RUZMEkk/9Rp"
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org,
	mcgrof@do-not-panic.com, kvalo@adurom.com, adrian.chadd@gmail.com
To: Johannes Stezenbach <js@sig21.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40326 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750986Ab3FVOWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jun 2013 10:22:00 -0400
In-Reply-To: <20130622101758.GA5427@sig21.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-FmH4EmV2+RUZMEkk/9Rp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-06-22 at 12:17 +0200, Johannes Stezenbach wrote:
> On Thu, Jun 20, 2013 at 11:40:38PM +0200, Johannes Berg wrote:
> >=20
> > On Tue, 2013-06-18 at 02:18 +0100, Ben Hutchings wrote:
>=20
> > > > +	/* Workaround for PCI problem when BIOS sets MMRBC incorrectly. *=
/
> > > > +	pci_read_config_word(hw->pdev, PCI_COMMAND, &val16);
> > > > +	if (!(val16 & ALX_PCI_CMD) || (val16 & PCI_COMMAND_INTX_DISABLE))=
 {
> > > > +		val16 =3D (val16 | ALX_PCI_CMD) & ~PCI_COMMAND_INTX_DISABLE;
> > > > +		pci_write_config_word(hw->pdev, PCI_COMMAND, val16);
> > > > +	}
> > > [...]
> > >=20
> > > I don't understand what this is trying to work around but it looks
> > > extremely dodgy.  The driver already appears to be doing
> > > pci_{save,restore}_state() in suspend/resume which is the right thing=
 to
> > > do.
> >=20
> > I have no idea, but ~PCI_COMMAND_INTX_DISABLE seems really just like
> > what we do with PCI_DEV_FLAGS_MSI_INTX_DISABLE_BUG... maybe this was
> > some sort of workaround for that.
> >=20
> > Johannes, can you try to remove this chunk of code and see if your
> > device still works? If so I'd just kill it.
>=20
> I removed it and did a full power cycle, alx still works.
> Also tried suspend-to-RAM and alx still works.  However,
> since the comment for this code is about BIOS bugs it might
> be that it is required on some other machine?  Not sure
> if it is wise to remove it...
>=20
> Another thing: When testing suspend-to-RAM my machine immediately
> woke up.  ethtool said wol is enabled by default:
>         Supports Wake-on: pg
> 	Wake-on: pg
> but even after "ethtool -s eth0 wol d" it still woke up.
> I did a few experiments, it seems that once the alx driver
> is loaded, even when the interface is down, the other end
> of the link (laptop with e1000e) reports the link goes
> into 10Mbit/s speed during suspend (actually it goes
> 1G -> down -> 10M),
[...]

Yes, the driver explicitly selects a lower link speed to save power
(alx_select_powersaving_speed()).  If WAKE_PHY is enabled, I think
alx_pre_suspend() needs to wait for link-up before returning.  Not sure
though.

Ben.

--=20
Ben Hutchings
Klipstein's 4th Law of Prototyping and Production:
                                    A fail-safe circuit will destroy others=
.

--=-FmH4EmV2+RUZMEkk/9Rp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUcWy/+e/yOyVhhEJAQrGKA//XtJX8QttQNypwdPAGm0MGW/QTS8Kvu7u
7Zx2FXzfWfLSA13ZvH3Nm7blNCzFjQqjc33sEGpyvkOcJO3PXDkFYVWEgo2cWxzN
bJZ89ZE7g2aBe3cQyVaAZIfmuGo7jWO+VNnF/B2l/KK4jyhMJ8qEAaKnlOybrgSl
mlte8nbB49YElZRzyvKCyWVQjj9zkmXZHgmHO7xYoPVHkKjfdILf7I5Mt09GdEW7
UuBOFytwf4RGpmvpDkYWhPLASphc4fv2MO4pbqLty+wbvJBp185cE08zB2CXYsw0
YC4kp52kgKGXmT06/pAVGLOD2jXaNjbDYng7QCunMY+TWX8/zbdfpi2cacN7z+z2
J5RZ4hjDQc1julEyEw3MhM/TnAtPzPYHwjzSPJgWJZYwKrwyEUF202Cg0ebgczAC
pi9YLYB6ZDJer2UuD/oY+NsM646pZZg+cb+GC7qcdPDmxW3TVgZ0HTP3G5z7fhlA
nDf9JFTS62JdcARauj6/ZOq1NtPGwPHgpyS7DUmLfqfQvyrTMJi8HIAg4STOfu8U
dw2MTk8JG8bm1qLu6crlKhx3UmG8gWHtak0UnZtL3N8sTWD+QJBQpAdtZrSbOgvo
5NJ0AVHA4+Q8YguDgz2V73rpjkty7LDLY7Wjue+SNd0WzgdNfKKlU89hRlzxIb0r
dyeicF8MimI=
=+IWh
-----END PGP SIGNATURE-----

--=-FmH4EmV2+RUZMEkk/9Rp--
