From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Thu, 4 May 2017 17:37:38 +0300
Message-ID: <20170504143738.GY22833@mtr-leonro.local>
References: <20170503235638.31116-1-stephen@networkplumber.org>
 <590AF624.6090808@iogearbox.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="+nG9yj4eE4W6Oba0"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:54598 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751427AbdEDOhc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 10:37:32 -0400
Content-Disposition: inline
In-Reply-To: <590AF624.6090808@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--+nG9yj4eE4W6Oba0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 04, 2017 at 11:36:36AM +0200, Daniel Borkmann wrote:
> On 05/04/2017 01:56 AM, Stephen Hemminger wrote:
> > Add support for extended ack error reporting via libmnl. This
> > is a better alternative to use existing library and not copy/paste
> > code from the kernel. Also make arguments const where possible.
> >
> > Add a new function rtnl_talk_extack that takes a callback as an input
> > arg. If a netlink response contains extack attributes, the callback is
> > is invoked with the the err string, offset in the message and a pointer
> > to the message returned by the kernel.
> >
> > Adding a new function allows commands to be moved over to the
> > extended error reporting over time.
> >
> > For feedback, compile tested only.
>
> Just out of curiosity, what is the plan regarding converting iproute2
> over to libmnl (ip, tc, ss, ...)? In 2015, tipc tool was the first
> user merged that requires libmnl, the only other user today in the
> tree is devlink, which even seems to define its own libmnl library
> helpers. What is the clear benefit/rationale of outsourcing this to
> libmnl? I always was the impression we should strive for as little
> dependencies as possible?

And I would like to get direction for the RDMA tool [1] which I'm
working on it now.

The overall decision was to use netlink and put it under iproute2
umbrella. Currently, I have working RFC which is based on
legacy sysfs interface to ensure that we are converging on
user-experience even before moving to actual netlink defines.

An I would like to continue to work on netlink interface, but which lib interface
should I need to base rdmatool's netlink code?

[1] https://www.mail-archive.com/netdev@vger.kernel.org/msg148523.html

>
> I don't really like that we make extended ack reporting now dependent
> on libmnl, which further diverts from iproute's native nl library vs
> requiring to install another nl library, making the current status
> quo even worse ... :/
>
> Thanks,
> Daniel

--+nG9yj4eE4W6Oba0
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkLPLIACgkQ5GN7iDZy
WKfjyg//esClwyjXcrIqdlbdUAk+p0RHa33VV1Ak+Q+VRI10Yv//Y3CsVxcZHPCm
m5TDqv9V4i0yxzghDU7KoDszluPN7GGikQcCG4u1UmWzZ4tQXlcKzKDjBznveib0
yy6vqrYrjZ7M07MmaCBtsiPYiReM9PLvPpzvM57UmkD1JFzMVpsogDOWQcm+PRm9
yVTJmkKDdTLY2BveUdbOa0RczP+42HhCJCGsFIidlINKfil6mRaTbX0J+YTWpt/2
qIeX2TrrAfzrL539XUYAJwgvGy3eqT4nCb6En4NgJ6XS7r/f9HCakR0HmcT1BFv5
79KcOvZW/s7ItGzpqL4SJKKK2XNu+SXn5maKrjGK8x22OtMFZp/ag5YoO7fS5wTt
QfAykaDFOWHQ+e93ETUYtKkiHzd3ZKhOu7G7R2pfDLVxSBWmoJjdgb7aWFGaMNg2
WoYGErM89sul1Y5vdTRB/HJx3IdDL0lusy4dC7C+EXpFi7DWRhS3plw7R7xxmh2h
5XD/gLTOUGv4eQlLhObmaeETbp//6hJprqb6GEiGV1zugZzOIN2MobfNJUOs+7u5
vCv+ZaydF2khxejGE2FcRH+wgy2kwUjszQ0uiR75ZGH/cTmbb6rVZm9ESims3rMp
N7aW177hTBfCD7XI6GPYoJITG+4wOnfgjb9XCrwLg4/xluje77g=
=PxZW
-----END PGP SIGNATURE-----

--+nG9yj4eE4W6Oba0--
