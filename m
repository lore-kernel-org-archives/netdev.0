From: David Miller <davem@davemloft.net>
Subject: Re: [patch] cipso: remove an unneeded NULL check in
 cipso_v4_doi_add()
Date: Tue, 11 Oct 2011 18:42:52 -0400 (EDT)
Message-ID: <20111011.184252.617974451481415643.davem@davemloft.net>
References: <20111011132228.GA27127@elgon.mountain>
	<CAHC9VhRMy-DbbkXSSWQPh8QgHAm5xzZ1qWJaYLiOERPagDfrbQ@mail.gmail.com>
	<20111011215549.GC30887@longonot.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paul@paul-moore.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53184 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590Ab1JKWps convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 18:45:48 -0400
In-Reply-To: <20111011215549.GC30887@longonot.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 12 Oct 2011 00:55:49 +0300

> On Tue, Oct 11, 2011 at 05:20:11PM -0400, Paul Moore wrote:
>> > - =A0 =A0 =A0 if (doi_def =3D=3D NULL || doi_def->doi =3D=3D CIPSO=
_V4_DOI_UNKNOWN)
>> > + =A0 =A0 =A0 if (doi_def->doi =3D=3D CIPSO_V4_DOI_UNKNOWN)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto doi_add_return;
>> > =A0 =A0 =A0 =A0for (iter =3D 0; iter < CIPSO_V4_TAG_MAXCNT; iter++=
) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (doi_def->tags[iter]) {
>>=20
>> I'd prefer to keep the NULL check in there as it does afford a littl=
e
>> bit of extra safety and this is management code after all, not
>> per-packet processing code, so the extra check should have no
>> observable performance impact.
>=20
> The dereferences on the lines before mean we would Oops before
> reaching the check.  But I guess I can move the check forward.  The
> error handling at goto doi_add_return relies on a non-NULL value for
> doi_def but I could just put a return in front of the dereference.
>=20
> 	if (!doi_def)
> 		return -EINVAL;
>=20
> I'll send a patch to do this tomorrow.

I think your original patch is still the best one.

Saying the NULL check should stay to provide "extra safety" is
complete garbage.  Especially since, as Dan shows, we dereference the
pointer before to damn check.

I'll therefore apply Dan's original patch.
