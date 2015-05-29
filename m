From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 7/7] Documentation: devicetree: add ar8xxx binding
Date: Thu, 28 May 2015 19:04:05 -0700
Message-ID: <5567C915.5090808@gmail.com>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org> <1432863742-18427-8-git-send-email-mathieu@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mathieu Olivari <mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org,
	gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, leitec-z4FmpzNVuK5Wk0Htik3J/w@public.gmane.org,
	fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org, alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	pavel.nakonechny-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, juhosg-p3rKhJxN3npAfugRpC6u6w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1432863742-18427-8-git-send-email-mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 05/28/15 18:42, Mathieu Olivari a =C3=A9crit :
> Add device-tree binding for ar8xxx switch families.
>=20
> Signed-off-by: Mathieu Olivari <mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> ---
>  .../devicetree/bindings/net/dsa/qca-ar8xxx.txt     | 70 ++++++++++++=
++++++++++
>  1 file changed, 70 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/dsa/qca-ar8=
xxx.txt
>=20
> diff --git a/Documentation/devicetree/bindings/net/dsa/qca-ar8xxx.txt=
 b/Documentation/devicetree/bindings/net/dsa/qca-ar8xxx.txt
> new file mode 100644
> index 0000000..f4fd3f1
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/dsa/qca-ar8xxx.txt
> @@ -0,0 +1,70 @@
> +* Qualcomm Atheros AR8xxx switch family
> +
> +Required properties:
> +
> +- compatible: should be "qca,ar8xxx"
> +- dsa,mii-bus: phandle to the MDIO bus controller, see dsa/dsa.txt
> +- dsa,ethernet: phandle to the CPU network interface controller, see=
 dsa/dsa.txt
> +- #size-cells: must be 0
> +- #address-cells: must be 2, see dsa/dsa.txt
> +
> +Subnodes:
> +
> +The integrated switch subnode should be specified according to the b=
inding
> +described in dsa/dsa.txt.
> +
> +Optional properties:
> +
> +- qca,port6-phy-mode: if specified, the driver will configure Port 6=
 in the
> +  given phy-mode. See Documentation/devicetree/bindings/net/ethernet=
=2Etxt for
> +  the list of valid phy-mode.

Is there a reason why this is a custom property and not a standard
"phy-mode" property here such that you could utilize of_get_phy_mode()
with this directly?

> +
> +- qca,port6-phy-id: if specified, the driver will connect Port 6 to =
the PHY
> +  given as a parameter. In this case, Port6 and the corresponding PH=
Y will be
> +  isolated from the rest of the switch. From a system perspective, t=
hey will
> +  act as a regular PHY.

Same here, is there a reason why this is not a "phy-handle" property to
a PHY node that sits on a (potentially different) MDIO bus?

> +
> +Example:
> +
> +	dsa@0 {
> +		compatible =3D "qca,ar8xxx";
> +		#address-cells =3D <2>;
> +		#size-cells =3D <0>;
> +
> +		dsa,ethernet =3D <&ethernet0>;
> +		dsa,mii-bus =3D <&mii_bus0>;
> +
> +		switch@0 {
> +			#address-cells =3D <1>;
> +			#size-cells =3D <0>;
> +			reg =3D <0 0>;	/* MDIO address 0, switch 0 in tree */
> +
> +			qca,port6-phy-mode =3D "sgmii";
> +			qca,port6-phy-id =3D <4>;
> +
> +			port@0 {
> +				reg =3D <11>;
> +				label =3D "cpu";
> +			};
> +
> +			port@1 {
> +				reg =3D <0>;
> +				label =3D "lan1";
> +			};
> +
> +			port@2 {
> +				reg =3D <1>;
> +				label =3D "lan2";
> +			};
> +
> +			port@3 {
> +				reg =3D <2>;
> +				label =3D "lan3";
> +			};
> +
> +			port@4 {
> +				reg =3D <3>;
> +				label =3D "lan4";
> +			};
> +		};
> +	};
>=20


--=20
=46lorian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
