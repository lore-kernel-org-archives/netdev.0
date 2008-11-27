From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 08/39] wimax: Mappping of generic netlink family IDs to
	net devices
Date: Thu, 27 Nov 2008 10:47:21 +0100
Message-ID: <1227779241.3809.36.camel@johannes.berg>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <6ffe4147aad336132ea57ae1bd950690d84fabbf.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-sOJsekxTae1p0wOfNPkc"
Cc: netdev <netdev@vger.kernel.org>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:35587 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbYK0JsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 04:48:07 -0500
In-Reply-To: <6ffe4147aad336132ea57ae1bd950690d84fabbf.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-sOJsekxTae1p0wOfNPkc
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:

> +/*
> + * wimax_get_netdev_by_info - lookup a wimax_dev from the gennetlink inf=
o
> + *
> + * The generic netlink family ID has been filled out in the
> + * nlmsghdr->nlmsg_type field, so we pull it from there, look it up in
> + * the mapping table and reference the wimax_dev.
> + *
> + * When done, the reference should be dropped with
> + * 'dev_put(wimax_dev->net_dev)'.
> + */
> +struct wimax_dev *wimax_dev_get_by_genl_info(struct genl_info *info)
> +{
> +	struct wimax_dev *wimax_dev;

=3D NULL;

> +	int id =3D info->nlhdr->nlmsg_type;
> +
> +	d_fnstart(3, NULL, "(info %p [id %d])\n", info, id);
> +	spin_lock(&wimax_id_table_lock);
> +	list_for_each_entry(wimax_dev, &wimax_id_table, id_table_node) {
> +		if (wimax_dev->gnl_family.id =3D=3D id) {
> +			dev_hold(wimax_dev->net_dev);
> +			goto out_unlock;

break;

> +		}
> +	}
> +	d_printf(1, NULL, "wimax: no device associated to ID %d\n", id);

remove debug statement (or make it depend on !wimax_dev)

> +	wimax_dev =3D NULL;
> +out_unlock:
> +	spin_unlock(&wimax_id_table_lock);
> +	d_fnend(3, NULL, "(info %p) =3D %p\n", info, wimax_dev);
> +	return wimax_dev;

No need for gotos any more :)

johannes

--=-sOJsekxTae1p0wOfNPkc
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJLmymAAoJEKVg1VMiehFY+9cP/AjU0ZJT4LmBrWIKLOGz/b8A
WTSnoIoLwYYx5eaCtHfD5uDIHCxbkGUJAwz6V81UbvYmAyXO2CecmL0N00H5K/Xz
SYE0WUWWlKVrA7C7NCde+Tq4DdeJBQE6oepkPQN8KWtlvLLt+ydJx/0VCvelZq7k
lhWpJBowFqLrNBbpxjWBi9xTIaic8dSiXfrOEXDTcVhwjMYrT/Y50n+fIfGdzDO0
jg8+3B2p46qA1KLu+F5YahN2wo1uWHcAoiWVTMt/ODuoBuYg8HdTTia7MXTjjWYP
d/dNYq6otc9Ya2dxK4dKoTxVdg+HdFusWDkGqeDRd2CWpcEDEJsR4lZuhhGkzJKK
pHUkmO/U3Hw6MpBQIlwIa5rVlvhr9cx1QiGobpP13h6tByws7YZrsLnBAxXn3C9A
UytO4UdEiFjTObFuyO4gSIH1zs8xoKuWGrm8eSbS+ITb0FmAD/W0+V2bi6pFC/VC
8IuTobijpdi6cPK8eN9kTu6r98Jy/1BWa/ayBt96z6rgt6yNhviPfkgljZdUqvKl
drx7dEUf8HQkdEGsQ/H1GI9YE1V2TXLVvBYbWRg5koGXy7Fu5lZrdlILeI+S2LEB
hORf3NqtHWwmnaHKb5/Co3D2NPok8q97GLmDrBljQ3S5rLD2t4QckorfX+ivQIm6
E9B5efcY6+7bRytgI9xS
=YbJI
-----END PGP SIGNATURE-----

--=-sOJsekxTae1p0wOfNPkc--

