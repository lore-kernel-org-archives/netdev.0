From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 09/39] wimax: provides user space with information
	needed when opening a WiMAX device
Date: Thu, 27 Nov 2008 13:20:25 +0100
Message-ID: <1227788425.3809.92.camel@johannes.berg>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <61e0e60ace9f0c441b51e5009d304229c4b234d3.1227691434.git.inaky@linux.intel.com>
	 <1227779589.3809.41.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-nwBklJMG2sPbBVmdF563"
Cc: netdev <netdev@vger.kernel.org>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:58506 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677AbYK0MVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 07:21:13 -0500
In-Reply-To: <1227779589.3809.41.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-nwBklJMG2sPbBVmdF563
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-11-27 at 10:54 +0100, Johannes Berg wrote:

> > +	result =3D -ENOMEM;
> > +	reply_skb =3D nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> > +	if (reply_skb =3D=3D NULL)
> > +		goto error_new;
> > +	data =3D genlmsg_put_reply(reply_skb, genl_info,
> > +				 &wimax_dev->gnl_family,
> > +				 0, WIMAX_GNL_RP_IFINFO);
> > +	if (data =3D=3D NULL)
> > +		goto error_put_reply;
> > +
> > +	nla_groups =3D nla_nest_start(reply_skb, WIMAX_GNL_IFINFO_MC_GROUPS);
> > +	if (nla_groups =3D=3D NULL)
> > +		goto error_groups_start;
> > +
> > +	list_for_each_entry(pipe_itr, &wimax_dev->pipe_list,
> > +			    list_node) {
> > +		nla_group =3D nla_nest_start(reply_skb,
> > +					   WIMAX_GNL_IFINFO_MC_GROUP);
> > +		if (nla_group =3D=3D NULL)
> > +			goto error_group_start;
> > +
> > +		nla_put_u16(reply_skb, WIMAX_GNL_IFINFO_MC_ID,
> > +			    pipe_itr->mcg.id);
> > +		nla_put_string(reply_skb, WIMAX_GNL_IFINFO_MC_NAME,
> > +			       pipe_itr->mcg.name);
>=20
> All this is discoverable via the genl controller and a pipe naming
> scheme, so I don't think you need this "open" command at all.

In fact, it's entirely trivial since you use a genl family for each
interface, thus you just have to ask the genl controller for the groups
associated with that family. If you need sample code, check out iw.

johannes

--=-nwBklJMG2sPbBVmdF563
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJLpCFAAoJEKVg1VMiehFYNL8QAL4uxLMjNAo9+IRt0PNk/5bx
+CZDcG9VSUvlS7ISwUO3vQRB05kWJ2oSZDwjnS1BYKtuyaqD00p+lLfTlfCiPy7A
wrcp9EXoV0y2p/+rt/ydfPWQQiKqhmfcrsZryLJi9ztR/TBraCIi483Q04SkmH9M
hHZnb2ZZZyAqw/BPDhDQWfBVVyYbtLZAb6lgp63cQC9oFxy/84u8QJnHf9m1J+zs
/nEHYVcKr9NWdsx1elGRrAOiY8iBUmdl5nw0DiGtUtsQ8MnDa9L3iVSn3fveemFU
1ai8HbU7q+rIbFdUQ7/4N4Js7mWI7fPBzwrKGdJ6z0CZOcvGQ65VukPMvC6FPyoF
g48yA8EDjS7cRWQfaDjgYgjHpuNW9PkCAXyCretGIWIb5sxOGiIAComQRfWzIYa3
Bpm4I0FJRAPorO1VqyaWtH5zLh2nPSZglRVeYoEn3Rjme2xGx2wvCHWxKUb+/q5A
4RX4B+NK7TigepkGpDkzZr7oG68ShUfV/ugmYCaXPpqyCIv6Zhkrzqjl8HSta6vD
ReWCSqWUyjpcZVvPqVQPKpAAhC6NHitFgYpwC/2o53Er3RVkIQ99U6EJyPHg02zb
RvoT42MjPgLCFKk6JWbh5az8mvsZan9udkM/LumtUsgZ+CXgJUPbYMWc/eQxEyT6
olzUp/SXGKQ3dDjK5KOx
=na9i
-----END PGP SIGNATURE-----

--=-nwBklJMG2sPbBVmdF563--

