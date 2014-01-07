From: Thomas Haller <thaller@redhat.com>
Subject: Re: [PATCH v2 2/2] ipv6 addrconf: don't cleanup route prefix for
 IFA_F_NOPREFIXROUTE
Date: Tue, 07 Jan 2014 19:32:57 +0100
Message-ID: <1389119577.2248.16.camel@weing>
References: <1389029375-17698-1-git-send-email-thaller@redhat.com>
	 <1389105553-21230-1-git-send-email-thaller@redhat.com>
	 <1389105553-21230-3-git-send-email-thaller@redhat.com>
	 <20140107162847.GB30393@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-mTrVBs+zQgSRxGs/uXbJ"
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13869 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752349AbaAGSdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 13:33:08 -0500
In-Reply-To: <20140107162847.GB30393@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mTrVBs+zQgSRxGs/uXbJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-01-07 at 17:28 +0100, Hannes Frederic Sowa wrote:
> On Tue, Jan 07, 2014 at 03:39:13PM +0100, Thomas Haller wrote:
> > Also, when adding the NOPREFIXROUTE flag to an already existing address=
,
> > check if there there is a prefix that was likly added by the kernel
> > and delete it.
>=20
> Hmm, could you give a bit more details why you have done this? I find
> that a bit counterintuitive. Maybe it has a reason?
>=20

Hi,

You find the behavior or the commit message counterintuitive? Didn't you
suggest this behavior in your email from "7 Jan 2014 13:01:11 +0100"?


For v3 I will reword the commit message. How about the following:

    ipv6 addrconf: don't cleanup prefix route for IFA_F_NOPREFIXROUTE
   =20
    Refactor the deletion/update of prefix routes when removing an
    address. Now, consider IFA_F_NOPREFIXROUTE and if there is an address
    present with this flag, to not cleanup the route. Instead, assume
    that userspace is taking care of this prefix.
   =20
    Also perform the same cleanup, when userspace changes an existing addre=
ss
    to add NOPREFIXROUTE to an address that didn't have this flag. We do th=
is
    because when the address was added, a prefix route was created for it.
    Since the user now wants to handle this route by himself, we remove it =
again.
   =20
    As before, a prefix route only gets removed, if there is no address
    that might need it. Or, if there are only non-permanent addresses,
    update the lifetime of the route.


ciao,
Thomas

--=-mTrVBs+zQgSRxGs/uXbJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABAgAGBQJSzEhaAAoJECnCNm5N/FcooIwP/RBpfKUPfZmqk6lzqAJCAOqc
QfrRMN12VfrukrykLcn5WQQsKDeidNfaCBSt4kyY97JWEhF/uKCl25XPjg93H3Ol
NkACIdIKMSZABfE4v63SELZ+/fd+1l+0+XjQBmj2WDH1oEjiE3p/xclJdZ8p9Wos
h74ZNpUSUbCup3aCh7IlM9AD+C20HdcjahnQPRDYZ8N0RixSYEV1CPus8D+VKB8F
R6pNDWOKaUNkT3PoVKUnAUvwWNB/mp5f/i7cJjQWrBt9VQ/CPWQUOhIm8WHcs0JB
n7BCTTQKNXi46QSQPoOz5ZFOdI7OQAyeW7XQrMqCsMT+kf80XGRhQT1GDpIXjbB7
kftPphVTnAwyxuxnqCsiu3yYhBUuk7Cf+iuFOgWa2XfA7iE1YQGchCANDm4IvZCT
1IodqQ+YczViDjpiyy3PubYk9mPBPboJNOBogEuxo3mlxJimCbB0EKyE8GNIDZnn
FcmO5wN+RnaF8fj/EbqFrvkMUPMe631Uy1o1LwK67MROSZ6EPq63hCgyR/k2NJlH
+asrRIAdrb+ISIh5oS9cWTNH/nbKGB5TziWJxnsNn1/fllWtSfWyPw9+Z/sXdYjK
Bu1g1T+wB2pz1WUhVXHEf8SdsJoQfgqtJCyRlRTnafczr6pjbdoH3Nj09GMmy91e
jWbkbpOVDd3nrSwegOcq
=KfRs
-----END PGP SIGNATURE-----

--=-mTrVBs+zQgSRxGs/uXbJ--
