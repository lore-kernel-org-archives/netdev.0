From: Florian Lohoff <flo@rfc822.org>
Subject: Re: 2.6.23-rc1 sky2 boot crash in sky2_mac_intr
Date: Tue, 24 Jul 2007 11:40:42 +0200
Message-ID: <20070724094042.GA6414@paradigm.rfc822.org>
References: <20070724082205.GA19480@paradigm.rfc822.org> <20070724095008.0eb154fe@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="rwEMma7ioTxnRzrJ"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935254AbXGXJlS@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070724095008.0eb154fe@oldman.hamilton.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 24, 2007 at 09:50:08AM +0100, Stephen Hemminger wrote:
> The problem is related to power management. The PHY has a number of PCI c=
onfiguration
> registers for power control, and the function of these changes based on t=
he version and
> revision of the chip. The driver does work on older versions of the EC-U,=
 in
> Fujitsu laptop's, it is just the new rev that is broken.
>=20
> The driver should probably fail smarter (by not loading) if the PHY isn't=
 powered
> up correctly, but that doesn't help your problem.
>=20
> The vendor has provided me with documentation on many versions
> of the chip, but I don't have doc's on the lastest revision differences o=
f the EC Ultra,=20
> so a proper solution is not easily available.  The best method for resolv=
ing this would
> be to first try the vendor driver version of sk98lin and see if that fixe=
s it. If so,
> then it is easy to change sky2, to match the phy setup in the vendor driv=
er.
> Another possibility is to look for places in sky2 driver where there are =
places
> that compare version/revision.
>=20
> The most likely bits that need to change are in PCI registers: 0x80, 0x84=
 and 0x88
> You could also load the windows driver and dump PCI config space (with ls=
pci from
> cygwin), and see what the settings are there.
>=20
> I am away from my office for a month, and therefore away from any sky2
> hardware for testing.=20

I'll try the above and keep you posted. The crash itself seems to be a
2.6.23-rc1 regression though. I never experienced this with 2.6.22-rc5
which i was running before.

Flo
--=20
Florian Lohoff                  flo@rfc822.org             +49-171-2280134
	Those who would give up a little freedom to get a little=20
          security shall soon have neither - Benjamin Franklin

--rwEMma7ioTxnRzrJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFGpckaUaz2rXW+gJcRAoNYAKCt3aq5A3B1lqUbvoO57TRfnOQG1wCguTMG
hCp1yaZ4hRGlLEem1zRgO4Q=
=G1dI
-----END PGP SIGNATURE-----

--rwEMma7ioTxnRzrJ--
