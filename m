From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH v2 7/8] net: mvmdio: add xmdio support
Date: Fri, 9 Jun 2017 16:56:30 +0200
Message-ID: <20170609145630.GE31464@kwain>
References: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
 <20170608092653.25221-8-antoine.tenart@free-electrons.com>
 <a60a0b26-62b1-7c9e-e846-215747dddb1f@gmail.com>
 <20170609082541.GC31464@kwain> <20170609132624.GC20756@lunn.ch>
 <20170609140922.GD31464@kwain> <20170609144936.GF20756@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0285793277834164112=="
Cc: thomas.petazzoni@free-electrons.com,
 Florian Fainelli <f.fainelli@gmail.com>, jason@lakedaemon.net,
 netdev@vger.kernel.org, Antoine Tenart <antoine.tenart@free-electrons.com>,
 linux@armlinux.org.uk, gregory.clement@free-electrons.com, mw@semihalf.com,
 davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
 sebastian.hesselbarth@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170609144936.GF20756@lunn.ch>
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


--===============0285793277834164112==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="brEuL7wsLY8+TuWz"
Content-Disposition: inline


--brEuL7wsLY8+TuWz
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Fri, Jun 09, 2017 at 04:49:36PM +0200, Andrew Lunn wrote:
> On Fri, Jun 09, 2017 at 04:09:22PM +0200, Antoine Tenart wrote:
> >=20
> > The MDIO/xMDIO registers are embedded into the network controller. The
> > mvmdio driver was created at first to abstract this functionality
> > outside the network controller driver because it is shared between all
> > ports and used in different IPs. So it's not really devices per say.
> >=20
> > Looking at the datasheet/schematics there are two hardware buses, one
> > for c22 and one for c45. So we should keep two separate nodes to
> > describe the two interfaces. From what I read c45 is backward
> > compatible with c22 so the xSMI interface should be capable to speak to
> > c22 PHYs as well.
>=20
> The on the wire protocol of c45 is backwards compatible with c22, in
> that a c22 device will not get confused by a c45 transaction on the
> bus. A c22 device will just ignore it. You cannot talk to a c22 device
> using c45.

I see.

> From what you are saying, you have a hardware block generating c45
> transactions and a hardware block which generates c22 transactions.
> What is not clear to me is if these two hardware blocks are using the
> same physical MDC/MDIO pins, i.e. there is just one MDIO bus to the
> outside world, or are there two busses?

There are two busses, one generating c22 transactions and one generating
c45 transactions. Each bus has its own MDC/MDIO pins.

> > And by looking at the datasheet this seems possible, although it's
> > not completely clear. But anyway this wouldn't impact the dt
> > bindings.
>=20
> What i'm worried about is there being one set of MDC/MDIO lines. You
> should not expose that to linux as two mdio busses. It is one bus.
>=20
> The phylib will poll each phy on the bus once per second to check its
> state. The phylib serialises the read/writes at a bus level. So if you
> have one physical bus registered as two logical bus, at some point you
> are going to get simultaneous read/writes, and you are going to need a
> mutex low down to serialise this for physical bus access.
>=20
> And in the end, this would affect the dt binding. If it is one
> physical bus, you want one binding representing both c22 and c45
> transactions.

Of course. See above.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--brEuL7wsLY8+TuWz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZOrceAAoJEFxNi8it27zYdDcQAIHcdqbFCah6T0DMyPbyfqsr
jaOSnMarYvE3or2pW+BYQCbYcHTao2GEXMCawSH+hegTIjvCmKqwFYIClvkBmEMY
3Em5JZkr3Cm/v0ExKQEuTTgHRtwYuUWLM1orR55T86yKmbn8R9GF+8FH1V6rJk+T
fsnz4zZ05Ue/P+aH/jF3O0AXeAZRH8hFaR8eWojb24W/R+Vhxq5N+Ei8GIGHBqD4
Swf5zivvxSyzQ29QEx9g4WJBF7TwqiobSrM+DRuUy8obbqM1NJUzdtknDd4Ct/wm
a/wfzg0v5b0plNKTDoTxB7MO5naXCIM5XNRlUR6PyrU7eMKzL+BwPLvJpK8U6aA2
YvSW+KQGv5Jpmlf/qYPu/7qLCvJor5WTaP/JMBD44DgJkhSImPtAx+HBo7rW4GlT
w+IewOjasXS8dFsww0xvaPj58OQbV236QLb6qb7ZgyY9i6+5TKhC6STHUqcgcAw9
APs9emJdBIjfxc7m+y3JqEeRNv5wQOuJaUOj6YyDzs41eVmoxNfc5Nw7ovfkYwp4
TJ8tj7DoYjyVLgvBw72MIhgXM5n8mcZJly9ARlOdMQpDNCvQz6VRe6kSx4kH1wr/
KEKIWTQzoAwzp+UPfn/dAOeKVOhiLbqtLiRQFtTAKfrtjv9IE2ooRVSHPWFxn64A
rSV2wFvGvZdt4d7eelOs
=6AlR
-----END PGP SIGNATURE-----

--brEuL7wsLY8+TuWz--


--===============0285793277834164112==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============0285793277834164112==--
