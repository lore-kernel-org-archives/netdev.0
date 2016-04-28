From: Josh Cartwright <joshc@ni.com>
Subject: Re: [PATCH v2] net: macb: do not scan PHYs manually
Date: Thu, 28 Apr 2016 16:03:57 -0500
Message-ID: <20160428210357.GB30217@jcartwri.amer.corp.natinst.com>
References: <1461854802-8142-1-git-send-email-nathan.sullivan@ni.com>
 <57222FCE.8050407@atmel.com>
 <20160428155556.GA8333@nathan3500-linux-VM>
 <20160428163207.GP29024@lunn.ch>
 <20160428175619.GA8791@nathan3500-linux-VM>
 <20160428184303.GR29024@lunn.ch>
 <20160428185527.GA8851@nathan3500-linux-VM>
 <20160428185932.GU29024@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="LpQ9ahxlCli8rRTG"
Cc: Nathan Sullivan <nathan.sullivan@ni.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160428185932.GU29024@lunn.ch>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--LpQ9ahxlCli8rRTG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 28, 2016 at 08:59:32PM +0200, Andrew Lunn wrote:
> On Thu, Apr 28, 2016 at 01:55:27PM -0500, Nathan Sullivan wrote:
> > On Thu, Apr 28, 2016 at 08:43:03PM +0200, Andrew Lunn wrote:
> > > > I agree that is a valid fix for AT91, however it won't solve our pr=
oblem, since
> > > > we have no children on the second ethernet MAC in our devices' devi=
ce trees. I'm
> > > > starting to feel like our second MAC shouldn't even really register=
 the MDIO bus
> > > > since it isn't being used - maybe adding a DT property to not have =
a bus is a
> > > > better option?
> > >=20
> > > status =3D "disabled"
> > >=20
> > > would be the unusual way.
> > >=20
> > >       Andrew
> >=20
> > Oh, sorry, I meant we use both MACs on Zynq, however the PHYs are on th=
e MDIO
> > bus of the first MAC.  So, the second MAC is used for ethernet but not =
for MDIO,
> > and so it does not have any PHYs under its DT node.  It would be nice i=
f there
> > were a way to tell macb not to bother with MDIO for the second MAC, sin=
ce that's
> > handled by the first MAC.
>=20
> Yes, exactly, add support for status =3D "disabled" in the mdio node.

Unfortunately, the 'macb' doesn't have a "mdio node", or alternatively:
the node representing the mdio bus is the same node which represents the
macb instance itself.  Setting 'status =3D "disabled"' on this node will
just prevent the probing of the macb instance.

  Josh

--LpQ9ahxlCli8rRTG
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXInq6AAoJEKp7ZBKwQFArjRgH/3bdmePZ1ycKMI0QBPRATrPq
pjF5MugHtpDh7HkryT2zZUW08cnJb4ZEboDXIQcenJzIe2dsTn1bcOS6XTBLKKMt
aGlltOPfWvG6bcEWDome1MzpSfYxQTObKAkrgq1pzE4Ljgwe0Y2qalTG8NlIJfhG
es4a4T+RFgPCOOqEUh1U+nR6KIEF8WIniMxBjWt6b+SHR1ZNvDpKHYcjDQh3MWfn
YlAnUcZ4za6nPHGMhBIjVMNQ6S4yEetIhn3NFPFOpl2drq0tTBs7jq6ySPeuRzGJ
NqaSwxQhzssCovyL2WCbjYrrizCIClcB5pF6YxnEPLufZjwbI3eYP19dxfDxZYk=
=X+Oa
-----END PGP SIGNATURE-----

--LpQ9ahxlCli8rRTG--
