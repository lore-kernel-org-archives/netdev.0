From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: wireless vs. network namespaces (part II)
Date: Mon, 29 Sep 2008 10:19:21 +0200
Message-ID: <1222676361.7064.11.camel@johannes.berg>
References: <1222509685.3798.59.camel@johannes.berg>
	 <m1r675aw0l.fsf@frodo.ebiederm.org>
	 <1222587651.3798.72.camel@johannes.berg>
	 <m1y71b8q1d.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-PUl5E4QTTd2YBIeCOK38"
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Jouni Malinen <j@w1.fi>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:50233 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642AbYI2ITh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 04:19:37 -0400
In-Reply-To: <m1y71b8q1d.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PUl5E4QTTd2YBIeCOK38
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-09-28 at 22:44 -0700, Eric W. Biederman wrote:

> So you are looking at using NETIF_F_NETNS_LOCAL to indicate that you can'=
t move
> one of the devices?

Yes.

> There is an UNREGISTER_NETDEV event and a REGISTER_NETDEV event sent when=
 a device
> is moved between namespaces.  See:  dev_change_net_namespace.

Yeah, I know.

> I think you would want to look onto those and move one network device whe=
n you
> move the other, without using NETIF_F_NETNS_LOCAL.
>=20
> Deletion and creation we have definitely done with paired veth devices.  =
I haven't
> looked at the migration case, but I with a little bit of guarding against=
 recursion
> it looks like it probably can be handled. =20
>=20
> Say trigger when your parnter device calls REGISTER_NETDEV in a different=
 network
> namespace?

Well, the's no inherent limit on the number of sibling devices, but
various conditions that the core code cannot fulfil because mac80211
also creates this master netdev (though it doesn't actually matter much
which ns it is in I guess). Right now I feel this is just too much to
ask. If anything, then I might want to allow moving a whole radio
("struct wiphy") at some point.

johannes

--=-PUl5E4QTTd2YBIeCOK38
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJI4I9+AAoJEKVg1VMiehFYciYQAI1LWFWfMJK9OKodWMlJ2IHS
LV9L4Bbvzuajd7TCn4gwzRjG0t0edxt5A6Lk15KJ1JYvbL1jpTVt0S3IcFBrdN6S
XFMawql0dtiC/YmTYFxEn5hKhSFxsePqCEqyzwLlJhtMGj3xSkU9FjhZBFGV0/0A
ctLwOr7WvU1nCmiGqaZNYMBKJeLq8QCp0gDIRSYFAYJjM17AKOVfhYP5TZeWKSyZ
B3a2Qq0b2H7kaiXm1P6Zfg18VFXunJL4/3nnH5D1svfPEA0RLA0tbOb0eYfW3jc1
5Bf1saBT62lScotvWdHW8wzNyE3N3mWitZOIQ4gsItKspbyYwhfTY5bHxY3Dv20/
uujOH7Iv5nsrq/YqG7Lsu07iIqBDWYFbUqoED4kmBLo+l3kIA3opsGw9FsbTnLP7
Y3/UC4oibdsMZnjw9Og9NBEh9v0yHgTqi/kDbtMo2rw0MjMFu+Z5bvbTfwWXZ/DH
ifa0VY8XgjPbcGsp8uDFFfG47ZFbl2CJXK3OYhzneNqCPrIAjVmZ52nRTjEvI2T8
6O1lwH3Yoj84E9uuh9SeKn8eQvTmu0jxk8w9IfUMccC4RVjo0YGC2wArEnyfeFx4
KwTWF7U4/69Zqh/HfZSG5+O0Px4EEdsCEf5VrKOMzjXN8+IW6RjOQ6e1PVWaO5s0
DhcsQV+cNa4FQM39ltdx
=bupr
-----END PGP SIGNATURE-----

--=-PUl5E4QTTd2YBIeCOK38--

