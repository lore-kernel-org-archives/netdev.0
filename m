From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Thu, 21 Feb 2008 11:17:22 +0100
Message-ID: <1203589042.17534.145.camel@johannes.berg>
References: <1203586467.20345.14.camel@brick>
	 <20080221.015743.222059206.davem@davemloft.net>
	 <1203588079.20345.15.camel@brick>
	 <20080221.020554.259219477.davem@davemloft.net>
	 (sfid-20080221_100524_615638_119EBE24)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-doU5oUUegdtVGrZUqBXG"
Cc: harvey.harrison@gmail.com, joe@perches.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:41756 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755589AbYBUKRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 05:17:33 -0500
In-Reply-To: <20080221.020554.259219477.davem@davemloft.net> (sfid-20080221_100524_615638_119EBE24)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-doU5oUUegdtVGrZUqBXG
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Thu, 2008-02-21 at 02:05 -0800, David Miller wrote:
> From: Harvey Harrison <harvey.harrison@gmail.com>
> Date: Thu, 21 Feb 2008 02:01:19 -0800
>=20
> > In this case, it's being passed to a debugfs create function, could it
> > instead use sysfs_format_mac?
>=20
> Just assigning print_mac() to a local variable then passing that to
> debugfs_create_dir() will make the warning go away.

Indeed, either of those will work.

> From another perspective adding that __pure attribute to print_mac()
> might not have been the best idea.  But I can't think of another
> way to elimitate the "passing print_mac() args to pr_debug()
> still generates calls to print_mac() even when DEBUG is not
> defined" problem :-/

Yeah, I saw that discussion. I think it's fine, it's just something we
need to be aware of. In fact, I Joe had a patch (that seems to have
gotten lost?) to make DECLARE_MAC_BUF() declare a structure with the u8
pointer in it instead to get type checking for the args, which would
make our code there not even compile, and imho rightfully so. I'll send
in a patch to fix this (via John) and Joe can resend his patch to get
typechecking there.

johannes

--=-doU5oUUegdtVGrZUqBXG
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR71PsaVg1VMiehFYAQJmYA//W7X9PUWnFQ6wwOMKrC3sMm7GuSSFWp7j
+BTWOOEQYzdAPJwVVa78Rr6ZbSmXxglEo6PdBuk3HoPL40d+JakB2ZtwtjLWYlgV
/rvsLfi/YJd1Rl3pxMoFx41JJg7j4tWDiuZD399o6LLnmFtgiU32vFMBybMsbPdZ
OJuXvePJqui8tEoxabkg6kbTLuOe/CXKJSEnV9hp6EZp57YCTMvT+Sip1cRSSaLY
eRm1TbXSaWVEBL2v+O87nf41Hh8m+FaimfWE386E8/yTh7yDhqJr3ZKRkXCLjMIG
LIgzl2UkIYxwiJZLBFwCMR0rnSq3lPz9bt3hrYQinXTp8PTI6ge5xvT1u0r6+9Mk
CEA2VTOolxGmKFbQr8ndX0SnC2T0beJzA9PEt2WtIsaIsrsnDxxmJf+796qD5fVV
YN4/jBXrv7jgkUZEYL1wX5XujudwKTpl9meGnZ7kNGxjdRbQ3qu7w44QxvIUpRLC
oGGrpxgi+VtsxZU0J61+GLnUMuB7OgUlnIOsHMoP7JzoxVijM5lblbCka3mMJME7
AZ+IAlhJ+qOqnWpw2HNa3OAel1e5E5r0kcMvA0aQOuaneX2KeRtnGlmDcr68x0ke
98BuXZ0DgqS8NtbEZQfvP68suy59jDQWxNm8sN1cZtmVfYZNstDmiBnirgjMmBYe
cv3yjZApvjk=
=MJpj
-----END PGP SIGNATURE-----

--=-doU5oUUegdtVGrZUqBXG--

