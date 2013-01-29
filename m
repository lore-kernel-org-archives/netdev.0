From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 2/2] drivers: net:ethernet: cpsw: add support for VLAN
Date: Tue, 29 Jan 2013 09:21:49 +0200
Message-ID: <20130129072149.GC7663@arwen.pp.htv.fi>
References: <1359403945-28585-1-git-send-email-mugunthanvnm@ti.com>
 <1359403945-28585-3-git-send-email-mugunthanvnm@ti.com>
 <20130128204446.GB5509@arwen.pp.htv.fi>
 <51075881.4050200@ti.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="E/DnYTRukya0zdZ1"
Cc: <balbi@ti.com>, <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:46842 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228Ab3A2HWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 02:22:19 -0500
Content-Disposition: inline
In-Reply-To: <51075881.4050200@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--E/DnYTRukya0zdZ1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Jan 29, 2013 at 10:35:05AM +0530, Mugunthan V N wrote:
> On 1/29/2013 2:14 AM, Felipe Balbi wrote:
> >On Tue, Jan 29, 2013 at 01:42:25AM +0530, Mugunthan V N wrote:
> >>adding support for VLAN interface for cpsw.
> >>
> >>CPSW VLAN Capability
> >>* Can filter VLAN packets in Hardware
> >>
> >>Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> >>---
> >>  Documentation/devicetree/bindings/net/cpsw.txt |    2 +
> >>  drivers/net/ethernet/ti/cpsw.c                 |  108 +++++++++++++++=
++++++++-
> >>  include/linux/platform_data/cpsw.h             |    1 +
> >>  3 files changed, 110 insertions(+), 1 deletion(-)
> >>
> >>diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documenta=
tion/devicetree/bindings/net/cpsw.txt
> >>index 6ddd028..99696bf 100644
> >>--- a/Documentation/devicetree/bindings/net/cpsw.txt
> >>+++ b/Documentation/devicetree/bindings/net/cpsw.txt
> >>@@ -24,6 +24,8 @@ Required properties:
> >>  Optional properties:
> >>  - ti,hwmods		: Must be "cpgmac0"
> >>  - no_bd_ram		: Must be 0 or 1
> >>+- default_vlan		: Specifies Default VLAN for non tagged packets
> >>+			  ALE processing
> >>  Note: "ti,hwmods" field is used to fetch the base address and irq
> >>  resources from TI, omap hwmod data base during device registration.
> >>diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/c=
psw.c
> >>index b35e6a7..dee6951 100644
> >>--- a/drivers/net/ethernet/ti/cpsw.c
> >>+++ b/drivers/net/ethernet/ti/cpsw.c
> >>@@ -32,6 +32,7 @@
> >>  #include <linux/of.h>
> >>  #include <linux/of_net.h>
> >>  #include <linux/of_device.h>
> >>+#include <linux/if_vlan.h>
> >>  #include <linux/platform_data/cpsw.h>
> >>@@ -72,6 +73,11 @@ do {								\
> >>  		dev_notice(priv->dev, format, ## __VA_ARGS__);	\
> >>  } while (0)
> >>+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
> >use IS_ENABLED() instead.
> Will change this in next patch version.
> >
> >>+#define VLAN_SUPPORT
> >>+#define CPSW_VLAN_AWARE_MODE
> >>+#endif
> >>+
> >>  #define ALE_ALL_PORTS		0x7
> >>  #define CPSW_MAJOR_VERSION(reg)		(reg >> 8 & 0x7)
> >>@@ -118,6 +124,14 @@ do {								\
> >>  #define TX_PRIORITY_MAPPING	0x33221100
> >>  #define CPDMA_TX_PRIORITY_MAP	0x76543210
> >>+#ifdef CPSW_VLAN_AWARE_MODE
> >>+#define CPSW_VLAN_AWARE		BIT(1)
> >>+#define CPSW_ALE_VLAN_AWARE	1
> >>+#else
> >>+#define CPSW_VLAN_AWARE		0x0
> >>+#define CPSW_ALE_VLAN_AWARE	0
> >>+#endif
> >you should really figure out a way of doing runtime detection for this.
> >Depending on driver recompilation just to enable/disable VLAN support
> >will be quite boring.
> I am not able to find a way to know whether stack is compiled with
> VLAN support or not
> without using VLAN_SUPPORT compiler option. Only way is to hack
> cpsw_ndo_vlan_rx_add_vid
> and know whether stack has VLAN capability or not which is not advisable.

you could use a module parameter or pass data to the driver. In any
case, relying completely on compile-time choices isn't very nice.

--=20
balbi

--E/DnYTRukya0zdZ1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRB3iNAAoJEIaOsuA1yqREGQIQAJnqbtliH3b36iXO+Jt1vZ4+
Ax+Lht/TX5wcnXToliYeC26HIC01UZjwIJY5IpUwi9IY3dWPHf56jXhxCm93atxm
dPREXowHepRI6uFS6RLciizSELigdOZe87FLvCYIm5/YYB02NO2WxsY7MyFNcpEV
fTxrHgCmgyoLvEwb2fhSEfcxIr4GyrNoCeISOxvbuzbw97Mf05NCDJL5PlGl1i/0
xskm0R5GnS84cdwXoNupRIWro/B0l5yTLRbS+oPcIS/9mZwulL2DUBTN0kxaxgeP
7HHuNPC9QoC2GsROwJOvMadk1vAtHg4Y0Ofltbh/cGbynOzjsEpsUrU4iI+hi8oV
TM8lbyTlIhJpcQOkgeKH8KZoGkPj6w2NGWQE8gEIMGR2u9qyamMLeiINmscU9pgD
13Gu2fCpwXu/yL6nV01nQjnjRacesujrhaKEyk8c80dHkxbITM/tmRziUyV4zHmw
hTmsVyDJuK7TJga0eBXMqGemLj3wTwy+weFEmbkimn/EFul2+zEoolFs7WHneMsJ
b5PyfUFjC66RY4wFAuqO0GHVAr3KUS5snA3wQZgxOeHNX/Z+L1aa8TSWt9/Zn1k2
czpXyZUO6Nf2DNk+6jnh9D3Ow4Fe1HMdX6Qp2WchBcM5P4bB4aT4114y6uKcFOzk
T6Nzs/+sEtlrQ3aqzHvA
=QaNp
-----END PGP SIGNATURE-----

--E/DnYTRukya0zdZ1--
