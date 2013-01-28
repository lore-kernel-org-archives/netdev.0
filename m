From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 2/2] drivers: net:ethernet: cpsw: add support for VLAN
Date: Mon, 28 Jan 2013 22:44:46 +0200
Message-ID: <20130128204446.GB5509@arwen.pp.htv.fi>
References: <1359403945-28585-1-git-send-email-mugunthanvnm@ti.com>
 <1359403945-28585-3-git-send-email-mugunthanvnm@ti.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4bRzO86E/ozDv8r1"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1359403945-28585-3-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--4bRzO86E/ozDv8r1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 29, 2013 at 01:42:25AM +0530, Mugunthan V N wrote:
> adding support for VLAN interface for cpsw.
>=20
> CPSW VLAN Capability
> * Can filter VLAN packets in Hardware
>=20
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> ---
>  Documentation/devicetree/bindings/net/cpsw.txt |    2 +
>  drivers/net/ethernet/ti/cpsw.c                 |  108 ++++++++++++++++++=
+++++-
>  include/linux/platform_data/cpsw.h             |    1 +
>  3 files changed, 110 insertions(+), 1 deletion(-)
>=20
> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentati=
on/devicetree/bindings/net/cpsw.txt
> index 6ddd028..99696bf 100644
> --- a/Documentation/devicetree/bindings/net/cpsw.txt
> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
> @@ -24,6 +24,8 @@ Required properties:
>  Optional properties:
>  - ti,hwmods		: Must be "cpgmac0"
>  - no_bd_ram		: Must be 0 or 1
> +- default_vlan		: Specifies Default VLAN for non tagged packets
> +			  ALE processing
> =20
>  Note: "ti,hwmods" field is used to fetch the base address and irq
>  resources from TI, omap hwmod data base during device registration.
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cps=
w.c
> index b35e6a7..dee6951 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -32,6 +32,7 @@
>  #include <linux/of.h>
>  #include <linux/of_net.h>
>  #include <linux/of_device.h>
> +#include <linux/if_vlan.h>
> =20
>  #include <linux/platform_data/cpsw.h>
> =20
> @@ -72,6 +73,11 @@ do {								\
>  		dev_notice(priv->dev, format, ## __VA_ARGS__);	\
>  } while (0)
> =20
> +#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)

use IS_ENABLED() instead.

> +#define VLAN_SUPPORT
> +#define CPSW_VLAN_AWARE_MODE
> +#endif
> +
>  #define ALE_ALL_PORTS		0x7
> =20
>  #define CPSW_MAJOR_VERSION(reg)		(reg >> 8 & 0x7)
> @@ -118,6 +124,14 @@ do {								\
>  #define TX_PRIORITY_MAPPING	0x33221100
>  #define CPDMA_TX_PRIORITY_MAP	0x76543210
> =20
> +#ifdef CPSW_VLAN_AWARE_MODE
> +#define CPSW_VLAN_AWARE		BIT(1)
> +#define CPSW_ALE_VLAN_AWARE	1
> +#else
> +#define CPSW_VLAN_AWARE		0x0
> +#define CPSW_ALE_VLAN_AWARE	0
> +#endif

you should really figure out a way of doing runtime detection for this.
Depending on driver recompilation just to enable/disable VLAN support
will be quite boring.

--=20
balbi

--4bRzO86E/ozDv8r1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRBuM+AAoJEIaOsuA1yqREXEMP/3AbO3CH3ngQrRqT2xMwPu75
65t5HyA/qZWakCAMErd+lU9ZFAcWYsU8Z02cRWKHWd4XOddo+8dSTzFNyPL2jK2t
D+vSD+wo7vV8wKJcv0mcd3wLN3n6A9LtKwoxwai+PnJBx90S8Fft9HtkzczzlwZd
/cP174qxbYgU4jVXc3Bf8ihgs+9cgJrv4fT1Sudm7UW8HKdc6tKF5ClssMSD2z6a
PSkhUsvIiqJggjyE+s35X/Zdl0PZDflGhCoB+sB9jfncFaGlTI3Y7FSRpi/s+Ncn
yZaCXHdKKv2Et4YZEBsMAWNWnrjpMbpkP+wdXG+17ukNDHwRD5YwpSNinBo2/HH9
W8LfEuDM8bWT7dROoa8IMlehYw0jpn3okNzULYT2KTJhp1Eh/d+SUsNJXs1wCHkf
MFctfh8HiR8c/dupmLsMnjNqtJFlEGDZZJ2pgoGPqlmtGA6COx4hKGQVTzbhGxiM
Kkd9RHo4RaMrTT8FFPZMV+sOhPIPPD3soGwDq3s4ahzPdkoN3fs1lHDin5K120/K
PKVrowlefawxhsslD3ohutFlnIGDKsIl1Yq8kZYRpvHKf7uH/CJaYNkk29sbjzky
dLhSEWMVNWFcbIlyBrIgsbtTuUWqsTkah+z5RLJCqKfml3Q+tGxW0T6PgsHqjZix
jW87vBzWoANTxplhnLOg
=O6vB
-----END PGP SIGNATURE-----

--4bRzO86E/ozDv8r1--
