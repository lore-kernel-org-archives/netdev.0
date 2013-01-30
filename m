From: Tom Parkin <tparkin@katalix.com>
Subject: Re: kmemleak complaints in ip6mr.c
Date: Wed, 30 Jan 2013 09:49:28 +0000
Message-ID: <20130130094928.GA2519@raven>
References: <20130129185127.GA31811@raven>
 <20130129.135906.1332264867631483230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3V7upXqbjpZ4EhLz"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:40073 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754437Ab3A3Jtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 04:49:36 -0500
Content-Disposition: inline
In-Reply-To: <20130129.135906.1332264867631483230.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 29, 2013 at 01:59:06PM -0500, David Miller wrote:
> From: Tom Parkin <tparkin@katalix.com>
> Date: Tue, 29 Jan 2013 18:51:27 +0000
>=20
> > I've discovered what may be a memory leak in ip6mr when using network
> > namespaces.  Here's the kmemleak backtrace:
> >=20
> >=20
> > unreferenced object 0xf0d4a180 (size 96):
> >   comm "ip", pid 6735, jiffies 4294949643 (age 73.268s)
> >   hex dump (first 32 bytes):
> >     68 a1 d4 f0 00 02 20 00 01 00 00 00 00 00 00 00  h..... .........
> >     00 00 00 00 00 00 00 00 00 00 00 00 ff 7f 00 00  ................
> >   backtrace:
> >     [<c159b50c>] kmemleak_alloc+0x2c/0x60
> >     [<c1139c23>] __kmalloc+0x1c3/0x240
> >     [<c14e2627>] fib_default_rule_add+0x27/0x70
> >     [<c157f8df>] ip6mr_net_init+0x6f/0x140
> >     [<c14c4129>] ops_init+0x39/0x110
> >     [<c14c425f>] setup_net+0x5f/0xf0
> >     [<c14c46e4>] copy_net_ns+0x74/0xf0
> >     [<c105fc81>] create_new_namespaces+0xd1/0x160
> >     [<c105fedf>] unshare_nsproxy_namespaces+0x5f/0xa0
> >     [<c1038a94>] sys_unshare+0x114/0x280
> >     [<c15b7ecd>] sysenter_do_call+0x12/0x28
> >     [<ffffffff>] 0xffffffff
>=20
> How is this memory unreferenced?  fib_rule_default_add() adds
> the allocated object to the ops->rules_list as it's very last
> action.

I think it should be freed by ip6mr_rules_exit() when the namespace is
destroyed.  That function calls fib_rules_unregister() on the stashed
ops pointer in net->ipv6.mr6_rules_ops.
--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--3V7upXqbjpZ4EhLz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJRCOyoAAoJEJSMBmUKuovQ8JcIAMTC62gwAKPddSU9oZODDNaQ
1L1/1TlFHjowO6fymiSXnwz0Ib2iEERGxD4STqY4wtO+T1ve0Le6B+uXLphUMrML
9sT9G/4T5c7tfPHKk7fJDqcIzjEOpl33ue/jngVXejyFw9aoBEHu6EGhWhxH3U1r
jcca4/fb0HWLf8VpAzURsdhNgtIDWjoAGnqsvlorgp1vuyjRGpFExA5hmAu6zwjj
lA4fHGOcjlo6iw+4cnwBR2LRPjzVjYQydkvtOv1iYxOSU3RA+UHUeHOWWyqSenc6
bohxcGxNo55zqY6IFy17DjFdt74OceZNCHTTDj7cWqXO56r7R2Ssn63J0ZQOUmM=
=Jadv
-----END PGP SIGNATURE-----

--3V7upXqbjpZ4EhLz--
