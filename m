From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Thu, 4 May 2017 20:55:56 +0300
Message-ID: <20170504175556.GZ22833@mtr-leonro.local>
References: <20170503235638.31116-1-stephen@networkplumber.org>
 <590AF624.6090808@iogearbox.net>
 <20170504143738.GY22833@mtr-leonro.local>
 <20170504094558.78933e60@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="9zecZT88ylESpiZX"
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:57296 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752938AbdEDRzw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 13:55:52 -0400
Content-Disposition: inline
In-Reply-To: <20170504094558.78933e60@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--9zecZT88ylESpiZX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 04, 2017 at 09:45:58AM -0700, Stephen Hemminger wrote:
> On Thu, 4 May 2017 17:37:38 +0300
> Leon Romanovsky <leon@kernel.org> wrote:
>
> > On Thu, May 04, 2017 at 11:36:36AM +0200, Daniel Borkmann wrote:
> > > On 05/04/2017 01:56 AM, Stephen Hemminger wrote:
> > > > Add support for extended ack error reporting via libmnl. This
> > > > is a better alternative to use existing library and not copy/paste
> > > > code from the kernel. Also make arguments const where possible.
> > > >
> > > > Add a new function rtnl_talk_extack that takes a callback as an input
> > > > arg. If a netlink response contains extack attributes, the callback is
> > > > is invoked with the the err string, offset in the message and a pointer
> > > > to the message returned by the kernel.
> > > >
> > > > Adding a new function allows commands to be moved over to the
> > > > extended error reporting over time.
> > > >
> > > > For feedback, compile tested only.
> > >
> > > Just out of curiosity, what is the plan regarding converting iproute2
> > > over to libmnl (ip, tc, ss, ...)? In 2015, tipc tool was the first
> > > user merged that requires libmnl, the only other user today in the
> > > tree is devlink, which even seems to define its own libmnl library
> > > helpers. What is the clear benefit/rationale of outsourcing this to
> > > libmnl? I always was the impression we should strive for as little
> > > dependencies as possible?
> >
> > And I would like to get direction for the RDMA tool [1] which I'm
> > working on it now.
> >
> > The overall decision was to use netlink and put it under iproute2
> > umbrella. Currently, I have working RFC which is based on
> > legacy sysfs interface to ensure that we are converging on
> > user-experience even before moving to actual netlink defines.
> >
> > An I would like to continue to work on netlink interface, but which lib interface
> > should I need to base rdmatool's netlink code?
> >
> > [1] https://www.mail-archive.com/netdev@vger.kernel.org/msg148523.html
> >
> > >
> > > I don't really like that we make extended ack reporting now dependent
> > > on libmnl, which further diverts from iproute's native nl library vs
> > > requiring to install another nl library, making the current status
> > > quo even worse ... :/
> > >
> > > Thanks,
> > > Daniel
>
> I would prefer new code use libmnl, but using libnetlink would also be ok.
> Any later conversion to libmnl would be mostly automated anyway.

Thanks, I'm copy/pasting devlink variation of libmnl :)

>
> The real objection was copy/pasting in the kernel netlink parser.
> That was unnecessary bloat.



--9zecZT88ylESpiZX
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkLaywACgkQ5GN7iDZy
WKdvIg//X8TGlNltK6mgRLUVRyq3GLw4q5f/4EvNT6+IKfjG1lZwDmOTzeNmPs9H
9WLAfyJb8ryl46P/tGdibPiOS3UL/XIchiR2yhXuq/ZBkLhes09jElp6BygnLYrU
iwOVHQDOttkjbcJ8efOI6cK2HQrB3zTRxuu7erxwjGDh54sbwpPpjpqyAeIOwOzv
Mq27pf6bvJOlzWT+df/eYJ2zWIAilkVM4ASZEKowmFvAeewj+7qyghWHrJ5MgVs/
ClRa/GMcrHsZmDOn0jrWLzwFoLbdFKrFTf+TuDba/b9M4WTGhSoGwpBPi4ue6kuV
r4sjQFz8sl5pOCKTH/xwaQNx5F0ps/ZKYfeXZnGCb1TQF1NyfsV37gFesrde5k0A
k7AQ4STeHeTG4b+48u9O4FkTOlJnvZpc40b8Vo74XYn6gz3DKGDDISHZV7mq3sXV
XPQQJy+ZW7Mzn/sUFX6wl5OIgvNbraJvNua/2JPeze9WMuJcq/F6JNq8IL3u4kqu
Ow4YxRsWkK5QrI1TeLt/Jd5HhDy85ma17ypW9fE4z5izf10VwFH7vbyGcXZO/YKM
D43vY0z84+MIcjh0PVfoHPJ6RDIQQOBNjRE4e5y6d8p6/JGoeRApsCGPqWleKqlQ
rULk8EHXP1d1SLPGZrWGdHp0Dmi79qlQ5E/W6f9okLG8dSzKZW4=
=fCzo
-----END PGP SIGNATURE-----

--9zecZT88ylESpiZX--
