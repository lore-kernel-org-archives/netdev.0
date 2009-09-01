From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Add DEVTYPE support for Ethernet based devices
Date: Tue, 01 Sep 2009 09:25:24 +0200
Message-ID: <1251789924.5327.4.camel@johannes.local>
References: <1251788899-30156-1-git-send-email-marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-fQL/tCK5C4qokEjvdy7g"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:40212 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbZIAHZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 03:25:28 -0400
In-Reply-To: <1251788899-30156-1-git-send-email-marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-fQL/tCK5C4qokEjvdy7g
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-09-01 at 00:08 -0700, Marcel Holtmann wrote:

> The new SET_NETDEV_DEVTYPE() is a convenience helper to set the actual
> device type. All device types are free form, but for convenience the
> same strings as used with RFKILL are choosen.

> --- a/net/mac80211/iface.c
> +++ b/net/mac80211/iface.c
> @@ -754,6 +754,10 @@ int ieee80211_if_change_type(struct ieee80211_sub_if=
_data *sdata,
>  	return 0;
>  }
> =20
> +static struct device_type wiphy_type =3D {
> +	.name	=3D "wlan",
> +};
> +
>  int ieee80211_if_add(struct ieee80211_local *local, const char *name,
>  		     struct net_device **new_dev, enum nl80211_iftype type,
>  		     struct vif_params *params)
> @@ -785,6 +789,7 @@ int ieee80211_if_add(struct ieee80211_local *local, c=
onst char *name,
> =20
>  	memcpy(ndev->dev_addr, local->hw.wiphy->perm_addr, ETH_ALEN);
>  	SET_NETDEV_DEV(ndev, wiphy_dev(local->hw.wiphy));
> +	SET_NETDEV_DEVTYPE(ndev, &wiphy_type);

Can't you move that into the NETDEV_REGISTER hook in cfg80211? That way
orinoco, rndis and iwm don't need updating now.

johannes

--=-fQL/tCK5C4qokEjvdy7g
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKnMxgAAoJEODzc/N7+QmakCQQAM67BYyZKKKmkfDfJk8c/FB8
+uKo7mIYJNAunFU8LgmDAVkRXn6lIvUfLlyWoXBOBHUrOpgO46DAbN1gtB+np7nx
D7ezigKtSV05Lzreiep8yQ2FRdLRSWmQzkDHeQqDKZHDjbrP1CT0qWgro5ncuSer
WDGLpWyG/sF0ZD/mkNa1XWu9as6qjDtMgZ33xrRnS8b4eB0xeTFGn8nHVvMzUZiY
DstA3VGztRBwcFOlsBs80fo9lusAXkRZxhxmfR4M8MmKouaVpwIbf2ypXcXtotan
ckdslBpoPp50d/cBmWN1yiKZdMBKhqDZZIWySNN6n102LbnVNaJLWp3o2EdFcyEN
tCt3BgbSuy+wQMUZi8597Xq8d52OZf9qcvehWdYZhQ5YDrN9l9PJjSAMdq5Nt6gZ
feJXfe4wjaqPIJevbO4gAdqRy0+mw6y5dim5IUzYcKc2VP43aTn7xK/TR+wlDESj
BupxZm0HqhQfLLPrGfexjVLAfT7hp5bqqWN3DW/lu7W7EcG5wvLDgJybqy1Wp7ae
RH5fKWCG01nDVq3dq66rZlmFVYXgLYbri9mj3cOMXEchvSxOzZRGAr+89LCobqKT
0ESf+lWt1TEi+o8e8kzaTxR4Cu9yRkxwhh020428pcFaYU4aQUaw7mbXCyInQ9lH
MKKD+In5x1uF2CgFiC3g
=Li22
-----END PGP SIGNATURE-----

--=-fQL/tCK5C4qokEjvdy7g--

