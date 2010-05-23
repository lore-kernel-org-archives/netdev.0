From: Dan Carpenter <error27@gmail.com>
Subject: Re: bug report: xfrm: potential null deref in xfrm_bundle_lookup()
Date: Sun, 23 May 2010 21:38:07 +0200
Message-ID: <20100523193645.GX22515@bicker>
References: <20100522202430.GN22515@bicker> <4BF96EA7.9050101@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:60988 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752938Ab0EWTi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 May 2010 15:38:26 -0400
Received: by vws9 with SMTP id 9so1945404vws.19
        for <netdev@vger.kernel.org>; Sun, 23 May 2010 12:38:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4BF96EA7.9050101@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 23, 2010 at 09:06:31PM +0300, Timo Ter=E4s wrote:
> On 05/22/2010 11:24 PM, Dan Carpenter wrote:
> > This is a smatch thing.  I couldn't tell if it was a real issue so =
I
> > thought I would send this mail to the experts.  :)
> >=20
> > net/xfrm/xfrm_policy.c +1679 xfrm_bundle_lookup(51)
> > 	error: we previously assumed 'xdst' could be null.
> >   1672          new_xdst =3D xfrm_resolve_and_create_bundle(pols, n=
um_pols, fl, family, dst_orig);
> >   1673          if (IS_ERR(new_xdst)) {
> >   1674                  err =3D PTR_ERR(new_xdst);
> >   1675                  if (err !=3D -EAGAIN)
> >   1676                          goto error;
> >   1677                  if (oldflo =3D=3D NULL)
> >   1678                          goto make_dummy_bundle;
> >   1679                  dst_hold(&xdst->u.dst);
> >                                   ^^^^^^^^^^^
> > 	Can xdst be NULL here?  It would have to be something like
> > 	oldflo gets passed in as null and __xfrm_policy_lookup() fails.
>=20
> No. xdst and oldflo point to same data structure, just to different
> offset (and data type). If oldflo is not null, xdst is not either. Se=
e
> their initialization around lines 1640. Since oldflo is explicitly
> tested for not being null, xdst is valid too.
>=20

Yeah yeah.  I'm a dummy.  From my email if "oldflo gets passed in as
null" then we hit the goto.  I was one small step away from understandi=
ng
it on my own.

Smatch actually would get this right if it understood that
container_of() basically never returns null.  It's a kind of grizzly
macro but I'll see if I can fix smatch to support that.

thanks again,
dan

