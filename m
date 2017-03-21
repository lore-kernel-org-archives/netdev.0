From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [v5,net-next,1/9] net: stmmac: multiple queues dt configuration
Date: Tue, 21 Mar 2017 12:32:45 +0100
Message-ID: <20170321113245.GA10526@ulmo.ba.sec>
References: <c315778b650a846db3c04816fd1d1041bb1e4043.1489169213.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="cWoXeonUoKmBZSoM"
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, niklas.cassel-VrBV9hrLPhE@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <c315778b650a846db3c04816fd1d1041bb1e4043.1489169213.git.jpinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 10, 2017 at 06:24:51PM +0000, Joao Pinto wrote:
> This patch adds the multiple queues configuration in the Device Tree.
> It was also created a set of structures to keep the RX and TX queues
> configurations to be used in the driver.
>=20
> Signed-off-by: Joao Pinto <jpinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
> ---
> Changes v4->v5:
> - patch title update (stmicro replaced by stmmac)
> Changes v2->v4:
> - Just to keep up with patch-set version
> Changes v1->v2:
> - RX and TX queues child nodes had bad handle
>=20
>  Documentation/devicetree/bindings/net/stmmac.txt   | 40 ++++++++++
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 91 ++++++++++++++++=
++++++
>  include/linux/stmmac.h                             | 30 +++++++
>  3 files changed, 161 insertions(+)
>=20
> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documenta=
tion/devicetree/bindings/net/stmmac.txt
> index d3bfc2b..4107e67 100644
> --- a/Documentation/devicetree/bindings/net/stmmac.txt
> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> @@ -72,6 +72,27 @@ Optional properties:
>  	- snps,mb: mixed-burst
>  	- snps,rb: rebuild INCRx Burst
>  - mdio: with compatible =3D "snps,dwmac-mdio", create and register mdio =
bus.
> +- Multiple RX Queues parameters: below the list of all the parameters to
> +				 configure the multiple RX queues:
> +	- snps,rx-queues-to-use: number of RX queues to be used in the driver
> +	- Choose one of these RX scheduling algorithms:
> +		- snps,rx-sched-sp: Strict priority
> +		- snps,rx-sched-wsp: Weighted Strict priority
> +	- For each RX queue
> +		- Choose one of these modes:
> +			- snps,dcb-algorithm: Queue to be enabled as DCB
> +			- snps,avb-algorithm: Queue to be enabled as AVB
> +		- snps,map-to-dma-channel: Channel to map
> +- Multiple TX Queues parameters: below the list of all the parameters to
> +				 configure the multiple TX queues:
> +	- snps,tx-queues-to-use: number of TX queues to be used in the driver
> +	- Choose one of these TX scheduling algorithms:
> +		- snps,tx-sched-wrr: Weighted Round Robin
> +		- snps,tx-sched-wfq: Weighted Fair Queuing
> +		- snps,tx-sched-dwrr: Deficit Weighted Round Robin
> +		- snps,tx-sched-sp: Strict priority
> +	- For each TX queue
> +		- snps,weight: TX queue weight (if using a weighted algorithm)
> =20
>  Examples:
> =20
> @@ -81,6 +102,23 @@ Examples:
>  		snps,blen =3D <256 128 64 32 0 0 0>;
>  	};
> =20
> +	mtl_rx_setup: rx-queues-config {
> +		snps,rx-queues-to-use =3D <1>;
> +		snps,rx-sched-sp;
> +		queue0 {
> +			snps,dcb-algorithm;
> +			snps,map-to-dma-channel =3D <0x0>;
> +		};
> +	};
> +
> +	mtl_tx_setup: tx-queues-config {
> +		snps,tx-queues-to-use =3D <1>;
> +		snps,tx-sched-wrr;
> +		queue0 {
> +			snps,weight =3D <0x10>;
> +		};
> +	};
> +
>  	gmac0: ethernet@e0800000 {
>  		compatible =3D "st,spear600-gmac";
>  		reg =3D <0xe0800000 0x8000>;
> @@ -104,4 +142,6 @@ Examples:
>  			phy1: ethernet-phy@0 {
>  			};
>  		};
> +		snps,mtl-rx-config =3D <&mtl_rx_setup>;
> +		snps,mtl-tx-config =3D <&mtl_tx_setup>;
>  	};

That's kind of an odd placement for these nodes. Wouldn't they be better
located within the controller's device tree node, rather than referenced
by phandle? Making them children of the root node leaves them completely
without context.

Thierry

--cWoXeonUoKmBZSoM
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljRD1sACgkQ3SOs138+
s6E2ihAAvzjSHlEXKv19FLXgDyTCKUzexrTl99xI6q35CB0hOwiZLvG2Boc8nCNZ
gdhhsT1MDV/2VlunRHt9KfWp1QmT0FIuQHRA6ZPpTAwWlszKFIRSka4c5w31kSmJ
U6Df8bu0azwp6iJ90c+Fq84IWtC1CeJfSXNB4QAWMDbcxqU2Cwj5lTcMdomILqya
ec9qOamNC1wF4nqvtQ0bQDz1CTsdb8ZNZCFpZR+0g33bRMpX7hRT0XRQ8FsjvcXv
APwqFyBxiYd6bX1hTKstxgW0JR8Lkep4c5MnuuhQTvWcBxN9Sg5vsBXqXDG/dWyf
UfNiHR5/Vn7R3rldp71q+/EjV+XPmCFTwAMam0LJbhGVauSv7yV/zr5oPXAaEBLV
fyPpBjxBTLxSYfmtqVpI5mj089HgPof7Qg+Mvoor4NKhU8BVjaor24dP1mkiFRSW
JLbBa3aF60We0xOKIX5A0kLca/aCLc2KsjAU/HuogceOmyBYIc1/LTIIIH5cFLNO
ex9JjmOq3GSm+MJ7y5v+/GQejqRRHQhv8+goyZEMdZbtWWipCbRtflddyeQ9wbq2
Wuvzbs3KoKIJt8z5N1GYGGnrGdsgQQywj39hSTMrpkbhfbfl1ViuqIo6j2/L0x1w
aj4O4aU/T2EeJ4JbreC1rp+1Az0Yg2NBKgP4hkdrEl0Vbv/c4ks=
=miiN
-----END PGP SIGNATURE-----

--cWoXeonUoKmBZSoM--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
