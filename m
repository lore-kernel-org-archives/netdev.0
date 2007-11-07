From: David Brownell <david-b@pacbell.net>
Subject: Re: [2.6 patch] usbnet.c: check for the right MII variable
Date: Wed, 7 Nov 2007 14:31:15 -0800
Message-ID: <200711071431.15525.david-b@pacbell.net>
References: <200711012024.57412.toralf.foerster@gmx.de> <200711011652.39601.david-b@pacbell.net> <20071102154615.GS30287@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adrian Bunk <bunk@kernel.org>,
	Toralf =?iso-8859-1?q?F=F6rster?= <toralf.foerster@gmx.de>,
	jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp111.sbc.mail.mud.yahoo.com ([68.142.198.210]:32571 "HELO
	smtp111.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758206AbXKGWbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 17:31:18 -0500
In-Reply-To: <20071102154615.GS30287@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 02 November 2007, Adrian Bunk wrote:
> <--  snip  -->
>=20
>=20
> This patch fixes the following compile error with CONFIG_MII=3Dm,=20
> CONFIG_USB_USBNET=3Dy, CONFIG_USB_USBNET_MII=3Dn:

This is the patch I liked better, if there was going to be
one going upstream without additional test from me ... sorry,
the patch you appear to have accepted was the worst of the
three patches in flight.

>=20
> <--  snip  -->
>=20
> ...
>   LD      .tmp_vmlinux1
> drivers/built-in.o: In function `usbnet_set_settings':
> (.text+0xf1876): undefined reference to `mii_ethtool_sset'
> drivers/built-in.o: In function `usbnet_get_settings':
> (.text+0xf1836): undefined reference to `mii_ethtool_gset'
> drivers/built-in.o: In function `usbnet_get_link':
> (.text+0xf18d6): undefined reference to `mii_link_ok'
> drivers/built-in.o: In function `usbnet_nway_reset':
> (.text+0xf18f6): undefined reference to `mii_nway_restart'
> make: *** [.tmp_vmlinux1] Error 1
>=20
> <--  snip  -->
>=20
> This bug was introduced by commit 18ee91fa9815fa3bb4e51cdcb8229bd0a0f=
11a70
> and reported by Toralf F=F6rster.
>=20
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
>=20
> ---
>=20
> BTW:
> The Kconfig part of this patch is not really required, but testing fo=
r
>   #if defined(CONFIG_USB_USBNET_MII) || defined(CONFIG_USB_USBNET_MII=
_MODULE)
> would look needlessly ugly.
>=20
>  drivers/net/usb/Kconfig  |    5 ++---
>  drivers/net/usb/usbnet.c |    7 +++----
>  2 files changed, 5 insertions(+), 7 deletions(-)
>=20
> a421e4910eb30b140a315e274632e87c7a218df6=20
> diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
> index 5a96d74..9261371 100644
> --- a/drivers/net/usb/Kconfig
> +++ b/drivers/net/usb/Kconfig
> @@ -94,12 +94,11 @@ config USB_RTL8150
>  	  module will be called rtl8150.
> =20
>  config USB_USBNET_MII
> -	tristate
> -	default n
> +	bool
> =20
>  config USB_USBNET
>  	tristate "Multi-purpose USB Networking Framework"
> -	select MII if USB_USBNET_MII !=3D n
> +	select MII if USB_USBNET_MII
>  	---help---
>  	  This driver supports several kinds of network links over USB,
>  	  with "minidrivers" built around a common network driver core
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index acd5f1c..7393ab0 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -683,8 +683,7 @@ done_nopm:
>   * they'll probably want to use this base set.
>   */
> =20
> -#if defined(CONFIG_MII) || defined(CONFIG_MII_MODULE)
> -#define HAVE_MII
> +#ifdef CONFIG_USB_USBNET_MII
> =20
>  int usbnet_get_settings (struct net_device *net, struct ethtool_cmd =
*cmd)
>  {
> @@ -744,7 +743,7 @@ int usbnet_nway_reset(struct net_device *net)
>  }
>  EXPORT_SYMBOL_GPL(usbnet_nway_reset);
> =20
> -#endif	/* HAVE_MII */
> +#endif	/*  CONFIG_USB_USBNET_MII  */
> =20
>  void usbnet_get_drvinfo (struct net_device *net, struct ethtool_drvi=
nfo *info)
>  {
> @@ -776,7 +775,7 @@ EXPORT_SYMBOL_GPL(usbnet_set_msglevel);
> =20
>  /* drivers may override default ethtool_ops in their bind() routine =
*/
>  static struct ethtool_ops usbnet_ethtool_ops =3D {
> -#ifdef	HAVE_MII
> +#ifdef CONFIG_USB_USBNET_MII
>  	.get_settings		=3D usbnet_get_settings,
>  	.set_settings		=3D usbnet_set_settings,
>  	.get_link		=3D usbnet_get_link,
>=20


