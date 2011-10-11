From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] cipso: remove an unneeded NULL check in
 cipso_v4_doi_add()
Date: Wed, 12 Oct 2011 00:55:49 +0300
Message-ID: <20111011215549.GC30887@longonot.mountain>
References: <20111011132228.GA27127@elgon.mountain>
 <CAHC9VhRMy-DbbkXSSWQPh8QgHAm5xzZ1qWJaYLiOERPagDfrbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	kernel-janitors@vger.kernel.org
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:20400 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747Ab1JKV7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 17:59:24 -0400
Content-Disposition: inline
In-Reply-To: <CAHC9VhRMy-DbbkXSSWQPh8QgHAm5xzZ1qWJaYLiOERPagDfrbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 11, 2011 at 05:20:11PM -0400, Paul Moore wrote:
> > - =A0 =A0 =A0 if (doi_def =3D=3D NULL || doi_def->doi =3D=3D CIPSO_=
V4_DOI_UNKNOWN)
> > + =A0 =A0 =A0 if (doi_def->doi =3D=3D CIPSO_V4_DOI_UNKNOWN)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto doi_add_return;
> > =A0 =A0 =A0 =A0for (iter =3D 0; iter < CIPSO_V4_TAG_MAXCNT; iter++)=
 {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (doi_def->tags[iter]) {
>=20
> I'd prefer to keep the NULL check in there as it does afford a little
> bit of extra safety and this is management code after all, not
> per-packet processing code, so the extra check should have no
> observable performance impact.

The dereferences on the lines before mean we would Oops before
reaching the check.  But I guess I can move the check forward.  The
error handling at goto doi_add_return relies on a non-NULL value for
doi_def but I could just put a return in front of the dereference.

	if (!doi_def)
		return -EINVAL;

I'll send a patch to do this tomorrow.

regards,
dan carpenter
