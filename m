From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Thu, 4 May 2017 09:45:58 -0700
Message-ID: <20170504094558.78933e60@xeon-e3>
References: <20170503235638.31116-1-stephen@networkplumber.org>
        <590AF624.6090808@iogearbox.net>
        <20170504143738.GY22833@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/nJj17.yvG2uW/dvHvr86LV/"; protocol="application/pgp-signature"
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:33161 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755410AbdEDQqC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 12:46:02 -0400
Received: by mail-pg0-f52.google.com with SMTP id y4so11432314pge.0
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 09:46:01 -0700 (PDT)
In-Reply-To: <20170504143738.GY22833@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/nJj17.yvG2uW/dvHvr86LV/
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 4 May 2017 17:37:38 +0300
Leon Romanovsky <leon@kernel.org> wrote:

> On Thu, May 04, 2017 at 11:36:36AM +0200, Daniel Borkmann wrote:
> > On 05/04/2017 01:56 AM, Stephen Hemminger wrote: =20
> > > Add support for extended ack error reporting via libmnl. This
> > > is a better alternative to use existing library and not copy/paste
> > > code from the kernel. Also make arguments const where possible.
> > >
> > > Add a new function rtnl_talk_extack that takes a callback as an input
> > > arg. If a netlink response contains extack attributes, the callback is
> > > is invoked with the the err string, offset in the message and a point=
er
> > > to the message returned by the kernel.
> > >
> > > Adding a new function allows commands to be moved over to the
> > > extended error reporting over time.
> > >
> > > For feedback, compile tested only. =20
> >
> > Just out of curiosity, what is the plan regarding converting iproute2
> > over to libmnl (ip, tc, ss, ...)? In 2015, tipc tool was the first
> > user merged that requires libmnl, the only other user today in the
> > tree is devlink, which even seems to define its own libmnl library
> > helpers. What is the clear benefit/rationale of outsourcing this to
> > libmnl? I always was the impression we should strive for as little
> > dependencies as possible? =20
>=20
> And I would like to get direction for the RDMA tool [1] which I'm
> working on it now.
>=20
> The overall decision was to use netlink and put it under iproute2
> umbrella. Currently, I have working RFC which is based on
> legacy sysfs interface to ensure that we are converging on
> user-experience even before moving to actual netlink defines.
>=20
> An I would like to continue to work on netlink interface, but which lib i=
nterface
> should I need to base rdmatool's netlink code?
>=20
> [1] https://www.mail-archive.com/netdev@vger.kernel.org/msg148523.html
>=20
> >
> > I don't really like that we make extended ack reporting now dependent
> > on libmnl, which further diverts from iproute's native nl library vs
> > requiring to install another nl library, making the current status
> > quo even worse ... :/
> >
> > Thanks,
> > Daniel =20

I would prefer new code use libmnl, but using libnetlink would also be ok.
Any later conversion to libmnl would be mostly automated anyway.

The real objection was copy/pasting in the kernel netlink parser.
That was unnecessary bloat.

--Sig_/nJj17.yvG2uW/dvHvr86LV/
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEn2/DRbBb5+dmuDyPgKd/YJXN5H4FAlkLWsYACgkQgKd/YJXN
5H5YBw/8DFq42EMNLZ1QJXYeYI/+Xb1z9AYksZ2cMSgpzVHyu46EZaVBtZGy1a/J
nrdg1jxhq/WOuUcUESmRdWRincuKZrh4j5gpP+hZ4109sxOZcGjd7IsTb+HFy4lI
BaAR8zJKVTv0rid2WSYKL73OuUVquolJvvpuOeUa7By2GCOXvi+AugbY+Bj2x2rR
19VUIudjqf7h7S3cmWVxjir2f+l3if+Pp8BrgbZVBeKz/icHVKmxvOlKMJyKPv58
RKGuqcmd53g/EVHndL060OPZpkMaKj1PwgSvO/ONdGnuK3e/7Pm7jTBy3rUhXRNc
n0ZxbRm0IFGUTD0jhgzXt8eml75ak/qNTLXY1sQQnBK/38GVGEyycglx6UD6m3GP
UJq1vgtloNz/gI4qUgMuidikpkdd1rR1VKrctXORjCL6rwIQXWoLUoq0LZb+tI8w
1EVr4Fc3BJJFJrb5l9lyn/D6POInbqbrABVl3X6S7K8NG662PYATzFa8/oH2GEbh
xRSDuBuisxk8azZDCTZL9dJhKgDqlDlgtMQ229kAP9wNQdiYRCTBI84hqjpnaoN2
7ElXZUxDlndl9iWGx7f9XB4+XL8Q1mP1lP+DPsozC60hKUbYZXrxz4+taHRVA0bp
O/rFYAHflaFa0Hjt8aEv2b/YECA/p3cWdePIE6iJc8t/NCi8SZw=
=E2fn
-----END PGP SIGNATURE-----

--Sig_/nJj17.yvG2uW/dvHvr86LV/--
