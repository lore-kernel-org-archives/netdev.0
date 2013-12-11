From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] Documentation: Add MDIO bus node to PHY binding document
Date: Wed, 11 Dec 2013 07:11:14 +0000
Message-ID: <3125212.eYMMS8pR1J@lenovo>
References: <1384174825-14249-1-git-send-email-jonas.jensen@gmail.com> <1384351669-8325-1-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: devicetree@vger.kernel.org, grant.likely@secretlab.ca,
	rob.herring@calxeda.com, linux-kernel@vger.kernel.org,
	mark.rutland@arm.com, netdev@vger.kernel.org
To: Jonas Jensen <jonas.jensen@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384351669-8325-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 13 novembre 2013, 15:07:49 Jonas Jensen a =E9crit :
> Add MDIO bus node segment and update the example,
> allowing trivial bindings to break out boilerplate.
>=20
> Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
> ---
>=20
> Notes:
>     Thanks Mark,
>=20
>     This should have the changes from your comments. It also adds opt=
ional
> properties "compatible" and "reg", were those overlooked or left out
> intentionally?

Please CC netdev@vger.kernel.org too as there might be some interest fr=
om=20
networking folks not actively following devicetree-discuss.

This does looks good to me, there is not much to be said to the point w=
here I=20
wonder if this even deserves such an example, but it cannot hurt.

>=20
>     Changes since v1:
>=20
>     1. reformat "MDIO bus node" description and add, node name should=
 be
> "mdio" 2. reformat property descriptions, describe what the cells rep=
resent
> 3. add optional properties
>     4. add a description after "PHY nodes"
>=20
>     Applies to next-20131113
>=20
>  Documentation/devicetree/bindings/net/phy.txt | 48
> ++++++++++++++++++++++----- 1 file changed, 40 insertions(+), 8
> deletions(-)
>=20
> diff --git a/Documentation/devicetree/bindings/net/phy.txt
> b/Documentation/devicetree/bindings/net/phy.txt index 7cd18fb..4179a7=
0
> 100644
> --- a/Documentation/devicetree/bindings/net/phy.txt
> +++ b/Documentation/devicetree/bindings/net/phy.txt
> @@ -1,5 +1,26 @@
> +MDIO Bus Nodes
> +
> +An MDIO bus node describes an MDIO bus, and is a container for PHY n=
odes
> +as described below. An MDIO bus node should be named "mdio".
> +
> +Required properties:
> +
> +- #address-cells =3D Should be <1>, specifies the number of cells ne=
eded
> +  to encode the PHY address
> +- #size-cells =3D Should be <0>
> +
> +Optional Properties:
> +
> +- compatible : Should contain a specific name for the MDIO bus,
> +  if known, followed by "-mdio"
> +- reg : Should contain register location and length
> +
> +
>  PHY nodes
>=20
> +Describes the PHY chip. A MAC connecting the PHY may use a phandle t=
o
> +this node.
> +
>  Required properties:
>=20
>   - device_type : Should be "ethernet-phy"
> @@ -23,13 +44,24 @@ Optional Properties:
>    assume clause 22. The compatible list may also contain other
>    elements.
>=20
> +
>  Example:
>=20
> -ethernet-phy@0 {
> -	compatible =3D "ethernet-phy-ieee802.3-c22";
> -	linux,phandle =3D <2452000>;
> -	interrupt-parent =3D <40000>;
> -	interrupts =3D <35 1>;
> -	reg =3D <0>;
> -	device_type =3D "ethernet-phy";
> -};
> +mdio {
> +	#address-cells =3D <1>;
> +	#size-cells =3D <0>;
> +
> +	ethernet-phy@0 {
> +		device_type =3D "ethernet-phy";
> +		compatible =3D "...", "ethernet-phy-ieee802.3-c22";
> +		reg =3D <0>;
> +		interrupts =3D <24 0>;
> +	}
> +
> +	ethernet-phy@1 {
> +		device_type =3D "ethernet-phy";
> +		compatible =3D "...";
> +		reg =3D <1>;
> +		interrupts =3D <35 1>;
> +	}
> +}

--=20
=46lorian
