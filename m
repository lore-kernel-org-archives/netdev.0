From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH 2/9] ipv6: sr: add code base for control plane support
 of SR-IPv6
Date: Mon, 17 Oct 2016 17:06:06 +0200
Message-ID: <5804E8DE.20200@uclouvain.be>
References: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be>       <1476715350-18983-3-git-send-email-david.lebrun@uclouvain.be> <20161017.110055.762862023679772858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="48B55FQGFcMNtXrOJsalFXWXvM4XRUfhb"
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:47533 "EHLO
        smtp3.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933512AbcJQPEj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 11:04:39 -0400
In-Reply-To: <20161017.110055.762862023679772858.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--48B55FQGFcMNtXrOJsalFXWXvM4XRUfhb
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 10/17/2016 05:00 PM, David Miller wrote:
> Please ordre local variables from longest to shortest line (AKA reverse=

> christmas tree layout).
>=20
> Please audit your entire submission for this problem.
>=20
>> +	val =3D (struct in6_addr *)nla_data(info->attrs[SEG6_ATTR_DST]);
>=20
> Please remove all casts from void pointers, they are completely unecess=
ary.
> Since nla_data() returns "(void *)", this applies here.
>=20
> Please audit your entire submission for this problem.
>=20

Will do

>> +	mutex_init(&sdata->lock);
>> +
>> +	sdata->tun_src =3D kzalloc(sizeof(*sdata->tun_src), GFP_KERNEL);
>> +	if (!sdata->tun_src) {
>> +		kfree(sdata);
>> +		return -ENOMEM;
>=20
> Best not to free an object while you still hold a mutex inside of it.
>=20
> Also taking the mutex makes no sense at all, this object has no global
> visibility, therefore no other thread of control can operate upon it.
>=20

The mutex is not taken, just initialized. Unless mutex_init takes the
lock, which would be quite strange ?


--48B55FQGFcMNtXrOJsalFXWXvM4XRUfhb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAlgE6OEACgkQjbzn67sZ6AMnbgCeM8Br8m0LNJmeUYswOB0q/xQc
dOwAn3A3pAtLFFL6YVob8Qdn7Xq5w908
=O9OI
-----END PGP SIGNATURE-----

--48B55FQGFcMNtXrOJsalFXWXvM4XRUfhb--
