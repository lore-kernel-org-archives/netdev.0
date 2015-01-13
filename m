From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 2/6] net: davinci_emac: Fix runtime pm calls for
 davinci_emac
Date: Tue, 13 Jan 2015 13:51:41 -0600
Message-ID: <20150113195141.GT16533@saruman>
References: <1421177368-19756-1-git-send-email-tony@atomide.com>
 <1421177368-19756-3-git-send-email-tony@atomide.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FfX2iGK5t5ehHnsE"
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Brian Hutchinson <b.hutchman@gmail.com>,
	Felipe Balbi <balbi@ti.com>,
	"Mark A. Greer" <mgreer@animalcreek.com>
To: Tony Lindgren <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:46253 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbbAMTw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 14:52:26 -0500
Content-Disposition: inline
In-Reply-To: <1421177368-19756-3-git-send-email-tony@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--FfX2iGK5t5ehHnsE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 13, 2015 at 11:29:24AM -0800, Tony Lindgren wrote:
> Commit 3ba97381343b ("net: ethernet: davinci_emac: add pm_runtime support=
")
> added support for runtime PM, but it causes issues on omap3 related devic=
es
> that actually gate the clocks:
>=20
> Unhandled fault: external abort on non-linefetch (0x1008)
> ...
> [<c04160f0>] (emac_dev_getnetstats) from [<c04d6a3c>] (dev_get_stats+0x78=
/0xc8)
> [<c04d6a3c>] (dev_get_stats) from [<c04e9ccc>] (rtnl_fill_ifinfo+0x3b8/0x=
938)
> [<c04e9ccc>] (rtnl_fill_ifinfo) from [<c04eade4>] (rtmsg_ifinfo+0x68/0xd8)
> [<c04eade4>] (rtmsg_ifinfo) from [<c04dd35c>] (register_netdevice+0x3a0/0=
x4ec)
> [<c04dd35c>] (register_netdevice) from [<c04dd4bc>] (register_netdev+0x14=
/0x24)
> [<c04dd4bc>] (register_netdev) from [<c041755c>] (davinci_emac_probe+0x40=
8/0x5c8)
> [<c041755c>] (davinci_emac_probe) from [<c0396d78>] (platform_drv_probe+0=
x48/0xa4)
>=20
> Let's fix it by moving the pm_runtime_get() call earlier, and also
> add it to the emac_dev_getnetstats(). Also note that we want to use
> pm_rutime_get_sync() as we don't want to have deferred_resume happen.
>=20
> Cc: Brian Hutchinson <b.hutchman@gmail.com>
> Cc: Felipe Balbi <balbi@ti.com>
> Cc: Mark A. Greer <mgreer@animalcreek.com>
> Signed-off-by: Tony Lindgren <tony@atomide.com>
> ---
>  drivers/net/ethernet/ti/davinci_emac.c | 14 ++++++++++----
>  1 file changed, 10 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/etherne=
t/ti/davinci_emac.c
> index 383ed52..deb43b3 100644
> --- a/drivers/net/ethernet/ti/davinci_emac.c
> +++ b/drivers/net/ethernet/ti/davinci_emac.c
> @@ -1538,7 +1538,7 @@ static int emac_dev_open(struct net_device *ndev)
>  	int i =3D 0;
>  	struct emac_priv *priv =3D netdev_priv(ndev);
> =20
> -	pm_runtime_get(&priv->pdev->dev);
> +	pm_runtime_get_sync(&priv->pdev->dev);

gotta check return value on all pm_runtime_get_sync() calls. IIRC,
there's a coccinelle script for checking and patching this.

--=20
balbi

--FfX2iGK5t5ehHnsE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUtXdNAAoJEIaOsuA1yqREbbIP/2pa66HHVsgsHF2VaMVhNZqU
Zd07YlO+ttBA4dFl/lbhoQYxY+m+6sP3IlB4jiLRnRD/lWXyZMSoPx8bjL91h9mJ
bSST/IQUV2nUonMM7zrbeAa0f1AJkdgEMNBGD5pypHZqKjQ+uI1L8Q7+JIvL4mA7
XM/r5HqUkIRCuqemkUyjUwgiSZ1tKuloynMteELshbyzuxRM5VJSA6ugeUSjPLRl
H7tATCrP3IBmkUNRYnCT4bdlXRMbRVt1jimTTqRbLHSwlOaMZmcstoNXD7HE9Cgy
f3f7UwBHhHlogcTF2iY0IRZfM5li3TdSfQZTq1tkJvQcTzv9yNJkGXvD+ufnKuwN
G5uFrJc0WsQY2ug0VgK6LnYVd3lw1KZyh3ppBhQJgVjk7gLNI3nDv9bU12PE2duf
CBsK7n94fHmqzhvJSRPuRQX/TL8mbDisD5/RPeQCK3VyDLaAqTayBM1hx6sT3cbD
0ik1RyodXSgCqzFrkaaORZh9ZNyjYErLZ2MkdUgMpn0tagheTDxxmPXrSLgVoIUT
Rjmr3XDli9nXgt6adxhYmm4ko4h0r815sITCQRBQTT3oiaql8BDZUASIM4enGJdl
m/cGUlIDVSijJjH7ia5u1sN1AnNgTHbYwSUgU+AefsM5tMmvW0fZixKbi4fniN1S
62nwfQMBx60JB8HSAT+A
=ksur
-----END PGP SIGNATURE-----

--FfX2iGK5t5ehHnsE--
