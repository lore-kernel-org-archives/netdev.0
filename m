From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v3 3/4] net: stmmac: register parent MDIO node for
 sun8i-h3-emac
Date: Thu, 24 Aug 2017 10:12:43 +0200
Message-ID: <20170824081243.ckihyjehv5derslx@flea.lan>
References: <CAGb2v67hQXSoCKP7qW+KRUYX+0djQ1Z23cQ67Lyg6G7ozGyfGQ@mail.gmail.com>
 <20170821132015.GB1703@lunn.ch>
 <20170821133104.qvrhvwin2rdg4aqo@flea.lan>
 <20170821142321.GE1703@lunn.ch>
 <CAGb2v64E4T=1ff3POGuXZA=MvjGAnKQ6OF6A3sT_cU-=jh6zNw@mail.gmail.com>
 <bfe784b6-5137-8fcd-dbd0-ad96974f4060@gmail.com>
 <20170822181140.GA11596@Red>
 <352ae66b-78a4-e88b-4544-a8edd9390b0c@gmail.com>
 <20170823074942.yt3c5gvnmdw5pqge@flea.home>
 <f14fe754-6339-32a0-3439-2daff6dd1d7e@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1259372643159867778=="
Cc: Mark Rutland <mark.rutland@arm.com>, Andrew Lunn <andrew@lunn.ch>,
 Alexandre Torgue <alexandre.torgue@st.com>,
 devicetree <devicetree@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
 Russell King <linux@armlinux.org.uk>,
 linux-kernel <linux-kernel@vger.kernel.org>, Chen-Yu Tsai <wens@csie.org>,
 Rob Herring <robh+dt@kernel.org>, Corentin Labbe <clabbe.montjoie@gmail.com>,
 Giuseppe Cavallaro <peppe.cavallaro@st.com>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <f14fe754-6339-32a0-3439-2daff6dd1d7e@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


--===============1259372643159867778==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="y63e2xmba6a4woqv"
Content-Disposition: inline


--y63e2xmba6a4woqv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 23, 2017 at 09:31:53AM -0700, Florian Fainelli wrote:
> On 08/23/2017 12:49 AM, Maxime Ripard wrote:
> > Hi Florian,
> >=20
> > On Tue, Aug 22, 2017 at 11:35:01AM -0700, Florian Fainelli wrote:
> >>>>> So I think what you are saying is either impossible or engineering-=
wise
> >>>>> a very stupid design, like using an external MAC with a discrete PHY
> >>>>> connected to the internal MAC's MDIO bus, while using the internal =
MAC
> >>>>> with the internal PHY.
> >>>>>
> >>>>> Now can we please decide on something? We're a week and a half from
> >>>>> the 4.13 release. If mdio-mux is wrong, then we could have two mdio
> >>>>> nodes (internal-mdio & external-mdio).
> >>>>
> >>>> I really don't see a need for a mdio-mux in the first place, just ha=
ve
> >>>> one MDIO controller (current state) sub-node which describes the
> >>>> built-in STMMAC MDIO controller and declare the internal PHY as a ch=
ild
> >>>> node (along with 'phy-is-integrated'). If a different configuration =
is
> >>>> used, then just put the external PHY as a child node there.
> >>>>
> >>>> If fixed-link is required, the mdio node becomes unused anyway.
> >>>>
> >>>> Works for everyone?
> >>>
> >>> If we put an external PHY with reg=3D1 as a child of internal MDIO,
> >>> il will be merged with internal PHY node and get
> >>> phy-is-integrated.
> >>
> >> Then have the .dtsi file contain just the mdio node, but no internal or
> >> external PHY and push all the internal and external PHY node definition
> >> (in its entirety) to the per-board DTS file, does not that work?
> >=20
> > If possible, I'd really like to have the internal PHY in the
> > DTSI. It's always there in hardware anyway, and duplicating the PHY,
> > with its clock, reset line, and whatever info we might need in the
> > future in each and every board DTS that uses it will be very error
> > prone and we will have the usual bunch of issues that come up with
> > duplication.
>=20
> OK, then what if you put the internal PHY in the DTSI, mark it with a
> status =3D "disabled" property, and have the per-board DTS put a status =
=3D
> "okay" property along with a "phy-is-integrated" boolean property? Would
> that work?

Yeah, that would work for me.

> What I really don't think is necessary is:
>=20
> - duplicating the "mdio" controller node for external vs. internal PHY,
> because this is not accurate, there is just one MDIO controller, but
> there may be different kinds of MDIO/PHY devices attached

Agreed.

> - having the STMMAC driver MDIO probing code having to deal with a
> "mdio" sub-node or an "internal-mdio" sub-node because this is confusing
> and requiring more driver-level changes that are error prone

I don't really have an opinion on that one, so I'll defer to your
judgment of what's best :)

I guess we have an agreement. Andrew, is that ok for you too?

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--y63e2xmba6a4woqv
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZnop7AAoJEBx+YmzsjxAgX3sP/2+1GGOFNI8oTWYkBjqUt5Bi
Tve9jBTHXEtApom0Tm8AITJ+fZBuCmO6FOfT73v3DbLjKrk3UIQr906zBycP0Yed
zH1EwtZivLuh/QSNqx4daqMSNdJOSk+47aSnph7/swSWo+8UV835pXwarwCPDCBy
hJ9Fk2PgSbN2DZ66jLCWt5DC1VK7bllGbs10XEAiPkRvdOOfyypR92YEHYSmGq48
7Xi04A8JN/z5dA9XzCCHyZD8LFFLtJ31zrIdXJA4uPnQRFw72CDKyudv8VOvRDJ3
wHNDmH7WCQJpiIjzk3qBCwhu7uTCil0rpTurWRZDeVzdbiY7uSp/V1kvYbrE3S5n
Ko/1oNIZZRen7G7ExKOglyahNfMzpDO9Ez/0BlT1hxs+62H+zrUuymg05Qr/kE8X
lo6dOOha16FAjtWmNLlfsUVqj0tAWphmShmojJXt62ze4kQJTTLf7hhqZK4mApCB
9eeY3MPHkEyV/D4fQVHail3kpQUouEQaFkn+qeLLvy7pjWBHxCktXkXAFVmy+G53
Symw7Yy9sZKnWgx1vHu581XmbQYLeYGcXC9CziifV0S7fM3zMCYLEg9KSc+BDj1U
KTFOGgOLk0/MjjkHrCnxtZLjCgiZZV/0nGv3RCjxafzyk8nfRFmnJgDczDNKkz/5
YaX5srxuEqjNfH3ZbHu8
=fW/6
-----END PGP SIGNATURE-----

--y63e2xmba6a4woqv--


--===============1259372643159867778==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============1259372643159867778==--
