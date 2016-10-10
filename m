From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v4 03/10] ARM: sun8i: dt: Add DT bindings documentation
 for Allwinner sun8i-emac
Date: Mon, 10 Oct 2016 14:30:23 +0200
Message-ID: <20161010123023.GG3462@lukather>
References: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com>
 <1475828757-926-4-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8714595577618894306=="
Cc: mark.rutland@arm.com, andrew@lunn.ch, f.fainelli@gmail.com,
 devicetree@vger.kernel.org, netdev@vger.kernel.org, linux@armlinux.org.uk,
 linux-kernel@vger.kernel.org, wens@csie.org, robh+dt@kernel.org,
 davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1475828757-926-4-git-send-email-clabbe.montjoie@gmail.com>
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


--===============8714595577618894306==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9Iq5ULCa7nGtWwZS"
Content-Disposition: inline


--9Iq5ULCa7nGtWwZS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 07, 2016 at 10:25:50AM +0200, Corentin Labbe wrote:
> This patch adds documentation for Device-Tree bindings for the
> Allwinner sun8i-emac driver.
>=20
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  .../bindings/net/allwinner,sun8i-emac.txt          | 70 ++++++++++++++++=
++++++
>  1 file changed, 70 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun8i=
-emac.txt
>=20
> diff --git a/Documentation/devicetree/bindings/net/allwinner,sun8i-emac.t=
xt b/Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt
> new file mode 100644
> index 0000000..92e4ef3b
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt
> @@ -0,0 +1,70 @@
> +* Allwinner sun8i EMAC ethernet controller
> +
> +Required properties:
> +- compatible: should be one of the following string:
> +		"allwinner,sun8i-a83t-emac"
> +		"allwinner,sun8i-h3-emac"
> +		"allwinner,sun50i-a64-emac"
> +- reg: address and length of the register for the device.
> +- syscon: A phandle to the syscon of the SoC
> +- interrupts: interrupt for the device
> +- clocks: A phandle to the reference clock for this device
> +- clock-names: should be "ahb"
> +- resets: A phandle to the reset control for this device
> +- reset-names: should be "ahb"
> +- phy-mode: See ethernet.txt
> +- phy-handle: See ethernet.txt
> +- #address-cells: shall be 1
> +- #size-cells: shall be 0
> +
> +Optional properties:
> +- allwinner,tx-delay: TX clock delay chain value. Range value is 0-0x07.=
 Default is 0)
> +- allwinner,rx-delay: RX clock delay chain value. Range value is 0-0x1F.=
 Default is 0)
> +Both delay properties does not have units, there are arbitrary value.
> +The TX/RX clock delay chain settings are board specific and could be fou=
nd
> +in vendor FEX files.
> +
> +Optional properties for "allwinner,sun8i-h3-emac":
> +- allwinner,leds-active-low: EPHY LEDs are active low
> +
> +Required child node of emac:
> +- mdio bus node: should be named mdio
> +
> +Required properties of the mdio node:
> +- #address-cells: shall be 1
> +- #size-cells: shall be 0
> +
> +The device node referenced by "phy" or "phy-handle" should be a child no=
de
> +of the mdio node. See phy.txt for the generic PHY bindings.
> +
> +Required properties of the phy node with "allwinner,sun8i-h3-emac":
> +- clocks: an extra phandle to the reference clock for the EPHY
> +- resets: an extra phandle to the reset control for the EPHY
> +
> +Example:
> +
> +emac: ethernet@01c0b000 {
> +	compatible =3D "allwinner,sun8i-h3-emac";
> +	syscon =3D <&syscon>;
> +	reg =3D <0x01c0b000 0x104>;
> +	interrupts =3D <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
> +	resets =3D <&ccu RST_BUS_EMAC>;
> +	reset-names =3D "ahb";
> +	clocks =3D <&ccu CLK_BUS_EMAC>;
> +	clock-names =3D "ahb";
> +	#address-cells =3D <1>;
> +	#size-cells =3D <0>;
> +
> +	phy =3D <&int_mii_phy>;
> +	phy-mode =3D "mii";
> +	allwinner,leds-active-low;
> +	mdio: mdio {
> +		#address-cells =3D <1>;
> +		#size-cells =3D <0>;
> +		int_mii_phy: ethernet-phy@1 {
> +			reg =3D <1>;
> +			clocks =3D <&ccu CLK_BUS_EPHY>;
> +			resets =3D <&ccu RST_BUS_EPHY>;

That works for me, let's see how the DT maintainers feel about it.

Thanks!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--9Iq5ULCa7nGtWwZS
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX+4neAAoJEBx+YmzsjxAgHIcQAKXoQcxK69NtiXkcMKymhYaM
3+kbkqf2FrCJHIIYQjDhaIeHVym11xCipXSmrg3bg5fNGyXRatGgoT7D99pHRGl4
4HhdT2gaKkz/GzCeCqdcqnub4hkW2G6f/6gGLC3bFpTkfjhmwE3/14Qmol/H7r9c
C3iuJFMJMgMFB0YlFXf3DQOrNBdrO32vdUy/e9zCBxPNRoOOCsnHI8yWgnVdiS2s
472lDkipuZ1D8ADvEJ8y7qfPby8HmmEexPiKjQ7393S/pWnEr4/LJMbp+eqJxrIU
gTf3FgUK5Wst3tp+o9s3Z2lDulpB5fA4Q/3c9eWY1kOlNoLoDzM8TWjcTsNEYqai
+XOfW0yWQKUfdeXZ3R4rjkdNPcwxsNjgwlcAwyOIP6GhOAg5P0BqN+HjPYyWcnvY
bYwu0TkkraprwHHKD5Ir9/959o1bj3heNNJutDc3LFVbef54osFhC+iJG4t7MdRI
Bdo04trOW5hPlANsEPFj0Ez46fAuzlwjmczFgwBHj8yTmh+2024o6/QFT0G9u5iR
DqJutWs4/PTTNpRO3zKu8lP00C6SQgd9fFrz2CrxYLueCeF6calOK+O6CbahXgxN
MSoZuWvhbRQO4s61iYhVBv8moTjuxilMgn34LYFCogLAux1pPmb3wvzyJ4E5r891
R+MEgbf5YVOtCFbf1S47
=2zbq
-----END PGP SIGNATURE-----

--9Iq5ULCa7nGtWwZS--


--===============8714595577618894306==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============8714595577618894306==--
