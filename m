From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] ARM: at91/dt: sama5d3 xplained: add phy address for macb1
Date: Fri, 3 Apr 2015 10:43:40 +0200
Message-ID: <551E52BC.3040702@atmel.com>
References: <1427792170-13162-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Johan Hovold <johan@kernel.org>, <stable@vger.kernel.org>
To: <linux-arm-kernel@lists.infradead.org>,
	Arnd Bergmann <arnd@arndb.de>, Olof Johansson <olof@lixom.net>,
	Kevin Hilman <khilman@kernel.org>,
	"ARM Maintainers" <arm@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427792170-13162-1-git-send-email-nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 31/03/2015 10:56, Nicolas Ferre a =E9crit :
> After 57a38effa598 (net: phy: micrel: disable broadcast for KSZ8081/K=
SZ8091)
> the macb1 interface refuses to work properly because it tries
> to cling to address 0 which isn't able to communicate in broadcast wi=
th
> the mac anymore. The micrel phy on the board is actually configured
> to show up at address 1.
> Adding the phy node and its real address fixes the issue.
>=20
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> Cc: Johan Hovold <johan@kernel.org>
> Cc: <stable@vger.kernel.org> #3.19
> ---

Arnd, Olof, Kevin,

It seems late but, is it possible to queue this patch as a 4.0 fixes?

Without it, the 10/100 Ethernet on sama5d3 doesn't work if it's not use=
d
by u-boot previously.

Bye,

>  arch/arm/boot/dts/at91-sama5d3_xplained.dts | 6 ++++++
>  1 file changed, 6 insertions(+)
>=20
> diff --git a/arch/arm/boot/dts/at91-sama5d3_xplained.dts b/arch/arm/b=
oot/dts/at91-sama5d3_xplained.dts
> index fec1fca2ad66..6c4bc53cbf4e 100644
> --- a/arch/arm/boot/dts/at91-sama5d3_xplained.dts
> +++ b/arch/arm/boot/dts/at91-sama5d3_xplained.dts
> @@ -167,7 +167,13 @@
> =20
>  			macb1: ethernet@f802c000 {
>  				phy-mode =3D "rmii";
> +				#address-cells =3D <1>;
> +				#size-cells =3D <0>;
>  				status =3D "okay";
> +
> +				ethernet-phy@1 {
> +					reg =3D <0x1>;
> +				};
>  			};
> =20
>  			dbgu: serial@ffffee00 {
>=20


--=20
Nicolas Ferre
