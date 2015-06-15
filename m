From: Simon Guinot <simon.guinot@sequanux.org>
Subject: Re: [PATCH 1/2] net: mvneta: introduce tx_csum_limit property
Date: Mon, 15 Jun 2015 17:54:41 +0200
Message-ID: <20150615155440.GS4853@kw.sim.vm.gnt>
References: <1434378443-23029-1-git-send-email-simon.guinot@sequanux.org>
 <1434378443-23029-2-git-send-email-simon.guinot@sequanux.org>
 <20150615164952.4f2f4dab@free-electrons.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0lx/R+CYDdR/AN/7"
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	stable@vger.kernel.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150615164952.4f2f4dab@free-electrons.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--0lx/R+CYDdR/AN/7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 15, 2015 at 04:49:52PM +0200, Thomas Petazzoni wrote:
> Dear Simon Guinot,
>=20
> On Mon, 15 Jun 2015 16:27:22 +0200, Simon Guinot wrote:
> > This patch introduces the tx_csum_limit DT property. This allows to
> > configure the maximum frame size for which the Ethernet controller is
> > able to perform TCP/IP checksumming. If MTU is set to a value greater
> > than tx_csum_limit, then the features NETIF_F_IP_CSUM and NETIF_F_TSO
> > are disabled.
> >=20
> > Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
> > Cc: <stable@vger.kernel.org> # v3.8+
> > ---
> >  .../bindings/net/marvell-armada-370-neta.txt       |  3 +++
> >  drivers/net/ethernet/marvell/mvneta.c              | 25 ++++++++++++++=
+++++++-
> >  2 files changed, 27 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/Documentation/devicetree/bindings/net/marvell-armada-370-n=
eta.txt b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
> > index 750d577e8083..db48c83ff0f5 100644
> > --- a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
> > +++ b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
> > @@ -8,6 +8,9 @@ Required properties:
> >  - phy-mode: See ethernet.txt file in the same directory
> >  - clocks: a pointer to the reference clock for this device.
> > =20
> > +Optional properties:
> > +- tx_csum_limit: max tx packet size for hardware checksum.
>=20
> To be honest, I'd prefer to have a different compatible string to
> identify the two different versions of the hardware block.
>=20
> The current armada-370-neta would limit the HW checksumming features to
> packets smaller than 1600 bytes, while a new armada-xp-neta would not
> have this limit.

This was also my first idea. But by doing this, we take the risk of
losing the HW checksumming feature with jumbo frames on some currently
working Armada XP setups. This may happen for example if a user is able
to update the kernel but not the on-board DTB. In order to fix a feature
on a SoC, we are breaking the DTB-kernel compatibility for the very same
feature on an another SoC. I am not sure it is OK.

Are you comfortable with that ?

By adding a new optional property, at least we ensure that the things
will still work the same way with Armada-XP SoCs (for every DTB-Linux
combination).

Please, let me know if you still want to introduce a compatible string
for Armada-XP.

Simon

>=20
> Yet another case where we should have used "armada-<soc>-neta",
> "armada-370-neta" in the .dtsi files for each SoC so that such
> modification do not require changing the Device Trees.
>=20
> Best regards,
>=20
> Thomas
> --=20
> Thomas Petazzoni, CTO, Free Electrons
> Embedded Linux, Kernel and Android engineering
> http://free-electrons.com

--0lx/R+CYDdR/AN/7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlV+9UAACgkQgtp0PDeOcDqOCACcDbj0319cbpJQhvPY66TzhFMI
1dQAnRf8vq91e0TksbhYk7eIjCY9W7X7
=esR2
-----END PGP SIGNATURE-----

--0lx/R+CYDdR/AN/7--
