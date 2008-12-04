From: Andre Schwarz <andre.schwarz@matrix-vision.de>
Subject: Re: "eth1: Could not attach to PHY" on MPC8349e-MITX
Date: Thu, 04 Dec 2008 18:56:40 +0100
Message-ID: <493819D8.8040300@matrix-vision.de>
References: <ed82fe3e0812040915i696e99bep75a37b0e38154415@mail.gmail.com>
	<49381662.2020302@matrix-vision.de>
	<493817AE.1070303@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linuxppc-dev@ozlabs.org, afleming@freescale.com, netdev@vger.kernel.org
To: Timur Tabi <timur@freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <493817AE.1070303@freescale.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Timur Tabi schrieb:
> Andre Schwarz wrote:
>   =

>> Timur,
>>
>> is it possible that the PHY adress doesn't match the one specified in
>> the dts ?
>>     =

>
> What part of the DTS contains the PHY address?  I have this:
>
> 	mdio@24520 {
> 		#address-cells =3D <1>;
> 		#size-cells =3D <0>;
> 		compatible =3D "fsl,gianfar-mdio";
> 		reg =3D <0x24520 0x20>;
>
> 		/* Vitesse 8201 */
> 		phy1c: ethernet-phy@1c {
> 			interrupt-parent =3D <&ipic>;
> 			interrupts =3D <18 0x8>;
> 			reg =3D <0x1c>;
> 			device_type =3D "ethernet-phy";
> 		};
> 	};
>
> 	enet1: ethernet@25000 {
> 		cell-index =3D <1>;
> 		device_type =3D "network";
> 		model =3D "TSEC";
> 		compatible =3D "gianfar";
> 		reg =3D <0x25000 0x1000>;
> 		local-mac-address =3D [ 00 00 00 00 00 00 ];
> 		interrupts =3D <35 0x8 36 0x8 37 0x8>;
> 		phy-connection-type =3D "mii";
> 		interrupt-parent =3D <&ipic>;
>   =

Your PHY is not on the MDIO bus, i.e. can not be programmed or queried.
Maybe your kernel lacks the mdio-less configuration ?
> 		/* Vitesse 7385 isn't on the MDIO bus */
> 		fixed-link =3D <1 1 1000 0 0>;
> 		linux,network-index =3D <1>;
> 	};
>
>   =



MATRIX VISION GmbH, Talstra=DFe 16, DE-71570 Oppenweiler  - Registergericht=
: Amtsgericht Stuttgart, HRB 271090
Gesch=E4ftsf=FChrer: Gerhard Thullner, Werner Armingeon, Uwe Furtner
