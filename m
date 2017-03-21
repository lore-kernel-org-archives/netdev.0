From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [v5,net-next,1/9] net: stmmac: multiple queues dt configuration
Date: Tue, 21 Mar 2017 13:10:07 +0100
Message-ID: <20170321121007.GD30407@ulmo.ba.sec>
References: <c315778b650a846db3c04816fd1d1041bb1e4043.1489169213.git.jpinto@synopsys.com>
 <20170321113245.GA10526@ulmo.ba.sec>
 <340aba35-de12-14a8-749c-5507edab449e@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="UoPmpPX/dBe4BELn"
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, niklas.cassel-VrBV9hrLPhE@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <340aba35-de12-14a8-749c-5507edab449e-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--UoPmpPX/dBe4BELn
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 21, 2017 at 11:39:24AM +0000, Joao Pinto wrote:
>=20
> Hi Thierry,
>=20
> =C3=80s 11:32 AM de 3/21/2017, Thierry Reding escreveu:
> > On Fri, Mar 10, 2017 at 06:24:51PM +0000, Joao Pinto wrote:
> >> This patch adds the multiple queues configuration in the Device Tree.
> >> It was also created a set of structures to keep the RX and TX queues
> >> configurations to be used in the driver.
> >>
> >> Signed-off-by: Joao Pinto <jpinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
> >> ---
> >> Changes v4->v5:
> >> - patch title update (stmicro replaced by stmmac)
> >> Changes v2->v4:
> >> - Just to keep up with patch-set version
> >> Changes v1->v2:
> >> - RX and TX queues child nodes had bad handle
> >>
> >>  Documentation/devicetree/bindings/net/stmmac.txt   | 40 ++++++++++
> >>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 91 +++++++++++++=
+++++++++
> >>  include/linux/stmmac.h                             | 30 +++++++
> >>  3 files changed, 161 insertions(+)
> >>
> >> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Docume=
ntation/devicetree/bindings/net/stmmac.txt
> >> index d3bfc2b..4107e67 100644
> >> --- a/Documentation/devicetree/bindings/net/stmmac.txt
> >> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> >> @@ -72,6 +72,27 @@ Optional properties:
> >>  	- snps,mb: mixed-burst
> >>  	- snps,rb: rebuild INCRx Burst
> >>  - mdio: with compatible =3D "snps,dwmac-mdio", create and register md=
io bus.
> >> +- Multiple RX Queues parameters: below the list of all the parameters=
 to
> >> +				 configure the multiple RX queues:
> >> +	- snps,rx-queues-to-use: number of RX queues to be used in the driver
> >> +	- Choose one of these RX scheduling algorithms:
> >> +		- snps,rx-sched-sp: Strict priority
> >> +		- snps,rx-sched-wsp: Weighted Strict priority
> >> +	- For each RX queue
> >> +		- Choose one of these modes:
> >> +			- snps,dcb-algorithm: Queue to be enabled as DCB
> >> +			- snps,avb-algorithm: Queue to be enabled as AVB
> >> +		- snps,map-to-dma-channel: Channel to map
> >> +- Multiple TX Queues parameters: below the list of all the parameters=
 to
> >> +				 configure the multiple TX queues:
> >> +	- snps,tx-queues-to-use: number of TX queues to be used in the driver
> >> +	- Choose one of these TX scheduling algorithms:
> >> +		- snps,tx-sched-wrr: Weighted Round Robin
> >> +		- snps,tx-sched-wfq: Weighted Fair Queuing
> >> +		- snps,tx-sched-dwrr: Deficit Weighted Round Robin
> >> +		- snps,tx-sched-sp: Strict priority
> >> +	- For each TX queue
> >> +		- snps,weight: TX queue weight (if using a weighted algorithm)
> >> =20
> >>  Examples:
> >> =20
> >> @@ -81,6 +102,23 @@ Examples:
> >>  		snps,blen =3D <256 128 64 32 0 0 0>;
> >>  	};
> >> =20
> >> +	mtl_rx_setup: rx-queues-config {
> >> +		snps,rx-queues-to-use =3D <1>;
> >> +		snps,rx-sched-sp;
> >> +		queue0 {
> >> +			snps,dcb-algorithm;
> >> +			snps,map-to-dma-channel =3D <0x0>;
> >> +		};
> >> +	};
> >> +
> >> +	mtl_tx_setup: tx-queues-config {
> >> +		snps,tx-queues-to-use =3D <1>;
> >> +		snps,tx-sched-wrr;
> >> +		queue0 {
> >> +			snps,weight =3D <0x10>;
> >> +		};
> >> +	};
> >> +
> >>  	gmac0: ethernet@e0800000 {
> >>  		compatible =3D "st,spear600-gmac";
> >>  		reg =3D <0xe0800000 0x8000>;
> >> @@ -104,4 +142,6 @@ Examples:
> >>  			phy1: ethernet-phy@0 {
> >>  			};
> >>  		};
> >> +		snps,mtl-rx-config =3D <&mtl_rx_setup>;
> >> +		snps,mtl-tx-config =3D <&mtl_tx_setup>;
> >>  	};
> >=20
> > That's kind of an odd placement for these nodes. Wouldn't they be better
> > located within the controller's device tree node, rather than referenced
> > by phandle? Making them children of the root node leaves them completely
> > without context.
> >=20
> > Thierry
> >=20
>=20
> I followed the same approach as "stmmac_axi_setup":
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/tree/D=
ocumentation/devicetree/bindings/net/stmmac.txt
>=20
> I personally find it cleaner and easier to read.

Okay, I see. I've never really seen this done, and I suspect the device
tree maintainers would've objected to the AXI bindings, but looks like
it fell through the cracks. Given that this has been upstream for a very
long time now, it is what it is, and I suppose this is at least
consistent.

Thierry

--UoPmpPX/dBe4BELn
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljRGB0ACgkQ3SOs138+
s6H3GA/9Enck0IzqaCgEAzpJUQ//T0+qqDdo9JlnnwrEQ0Q9YwBpLENabCOaSKh6
w0pzBkzfT9r/IYLHG1KOffiehfJpWUJs1RW9nDtHpiVlV5Or0VsE7VWQv+4RO93u
5qKwvji1fInwPXFy5wb+oKV4KFz1+re2kCdLhLGZw2YgZT0XbeyFj+Ml/5mTd43I
w6g84qpvqQ0zenfLBzP3ZSM+tQiYutiMre4JBeOKramI0Wff0mLx5nwwMgsnp3O4
daYrhF6BENvPJtP2THpIzyhFnGccRQMpa+fNaLcxq4yEFFmj4XsMvhaYEP5xX63d
1iRb/nFgTPUG3IWHHoUawv4HBK0ixWA+7AR9FJDbrLzmiZFiwItCmOh22etvj7F0
1ZF5Kv1eafqpw8b5OjuoI8OiuUkUAnjkkEEG2t9l8gMPcNg146iFlxqTXCgTVvWL
WMcoyPT/+9ro/VtrdFuGuHFVQ2sFK0099+JDX8ViSupxMhphWQj8LPaa+3L9CE6Q
OkLOhruY7dm+78PISa0nGJ6Me0BBlHPdqxWyRnepka0QNy1WiG1ERaqXqTP3HH/5
4Rv7IuJNxqIulhLbQ77lsNa3ia9IFE6pLTEZ9d6ZQRWcVsrOdvjMpX+7ptyU47q2
jpbDe9d8jGaUjIwMXOx+4b/ba6FdhGZAxcRSywtY54dcV4AO7Lw=
=eQP7
-----END PGP SIGNATURE-----

--UoPmpPX/dBe4BELn--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
