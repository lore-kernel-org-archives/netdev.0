From: Thomas Haller <thaller@redhat.com>
Subject: Re: [PATCH v2 2/2] ipv6 addrconf: don't cleanup route prefix for
 IFA_F_NOPREFIXROUTE
Date: Tue, 07 Jan 2014 23:54:22 +0100
Message-ID: <1389135262.2248.42.camel@weing>
References: <1389029375-17698-1-git-send-email-thaller@redhat.com>
	 <1389105553-21230-1-git-send-email-thaller@redhat.com>
	 <1389105553-21230-3-git-send-email-thaller@redhat.com>
	 <20140107162847.GB30393@order.stressinduktion.org>
	 <1389119577.2248.16.camel@weing>
	 <20140107190148.GD30393@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-cMOv97Vci0eGNBMuDmte"
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24621 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753585AbaAGWyc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 17:54:32 -0500
In-Reply-To: <20140107190148.GD30393@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-cMOv97Vci0eGNBMuDmte
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-01-07 at 20:01 +0100, Hannes Frederic Sowa wrote:
> On Tue, Jan 07, 2014 at 07:32:57PM +0100, Thomas Haller wrote:
> > On Tue, 2014-01-07 at 17:28 +0100, Hannes Frederic Sowa wrote:
> > > On Tue, Jan 07, 2014 at 03:39:13PM +0100, Thomas Haller wrote:
> > > > Also, when adding the NOPREFIXROUTE flag to an already existing add=
ress,
> > > > check if there there is a prefix that was likly added by the kernel
> > > > and delete it.
> > >=20
> > > Hmm, could you give a bit more details why you have done this? I find
> > > that a bit counterintuitive. Maybe it has a reason?
> > >=20
> >=20
> > You find the behavior or the commit message counterintuitive? Didn't yo=
u
> > suggest this behavior in your email from "7 Jan 2014 13:01:11 +0100"?
>=20
> I guess I was a bit confused, sorry. I think I confused the deleted and m=
odify
> case. However:
>=20
> So we have the following changes on addresses:
>=20
> add is simple: just as in the first patch
>=20
> modify: is a bit hairy. To be extremly exact, we would have to recreate t=
he
> 	route with proper metrics etc. so delete in any case and reinsert.
> 	I really dislike removing a route someone else might have inserted
> 	manually, and this is a likely scenario.
>=20
> 	Somehow I tend to just don't allow NOPREFIXROUTE on modify at all and
> 	just return a proper error value. What do you think? What would be the
> 	best behavior for NM?
>=20
> delete: if IFA_F_NOPREFIXROUTE is set, we don't care about removing a pre=
fix
> 	route, it must be set by user space and should get cleaned up by user
> 	space
>=20
> >=20
> >=20
> > For v3 I will reword the commit message. How about the following:
> > ...
>=20
> If we want go with the current modify behavior this sounds good.


Hi,


I think, the modify case is not that hairy and the patch does IMO the
sensible thing:

case 1) "change NOPREFIXROUTE -> !NOPREFIXROUTE":
    update or add prefix route (as before);;
case 2) "change !NOPREFIXROUTE -> !NOPREFIXROUTE":
    update or add prefix route (as before);;
case 3) "change NOPREFIXROUTE -> NOPREFIXROUTE":
    ;;
case 4) "change !NOPREFIXROUTE -> NOPREFIXROUTE":
    cleanup prefix route;;

where "cleanup" means the same as done in ipv6_del_addr(), as determined
by check_cleanup_prefix_routes().


Allowing modify with case 2) and 3) is important. But for case 4) (and
possibly 1)), we could also fail with error. I tend to the scheme above
though because it makes it easier for userspace and is likely what it
wants.



The problem of deleting a route created by somebody else is already
present without this patch in ipv6_del_addr. This is indeed a bit shaky,
but I guess it's good enough in practice. Do I understand correctly,
that you think about to use the information from ifp->rt to ensure, that
what we really cleanup the correct route? If that's what you intend, can
you elaborate a bit on how to do that?


ciao,
Thomas


--=-cMOv97Vci0eGNBMuDmte
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABAgAGBQJSzIWeAAoJECnCNm5N/FcoP04P/0exGVSTFJZbv8gcoPnlAatE
3Klok/zBtt/tm74JRTrNMKVvk4cJDc3gXsdkiSw3rqM5rPVK139j+42zjW9VwiOu
J3guMRJIjP7d+SBPWOQYEuAkJNjc1Jgv0mNPivMWFDc6Sh0nFTX3VQ6f60LDY3ue
ZXLH+D1Be4eYJM9LKUka7RPA54YHd4XOkXVDSgDfpI/SZjeNF3k3e2q18LVpyhCm
i65zpwclbe5XUXpJZdBmdVPuNUgd37pq5VqerMt/aPDfeVY9+0cl3R4k3mgBf9F0
E1EtrYhD9122B4sBAPxXgkmUIvUEcBwHvrODWjREfGx2TMEgXHDtVpYTq4njeD4C
LrjSZyI9OIqQK8ovYg2VSiXBMFb1B01e3bLFAHAnbw4cnNmyXIR/pHX9YfKpVH82
mG36ARR1GUWrESyDOFQnPWhcwaDvDZgWSdxbhCnbsW8uZjvO/bXtzDkIor7jbNPk
1JtUVIyiQBrqzPxOUu403btRl0SwKMPT5bxMSCfooaq2iZswRuO1Zx2Xu5LAwMAz
ti8oI39uB5SqdvLDGeaoYuSObmb/1KAEpEJ77M2Txwdv1djBOhfdsz1HvbusBp97
08Yk8Rv011ZWrQnm4yT+ekHFJm6qFSZnvUnPUVLF8QQ7nyw2/DsnLpxYpA7auYIb
Sx69vWtWJrEsJ2hkqmA4
=vgoS
-----END PGP SIGNATURE-----

--=-cMOv97Vci0eGNBMuDmte--
