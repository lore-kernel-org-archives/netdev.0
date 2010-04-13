From: Michal Svoboda <michal.svoboda@agents.felk.cvut.cz>
Subject: Re: SO_REUSEADDR with UDP (again)
Date: Tue, 13 Apr 2010 13:27:26 +0200
Message-ID: <20100413112726.GB16595@myhost.felk.cvut.cz>
References: <20100413093408.GA16595@myhost.felk.cvut.cz>
 <1271155163.16881.244.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Pd0ReVV5GZGQvF3a"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.felk.cvut.cz ([147.32.80.7]:59143 "EHLO
	relay.felk.cvut.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021Ab0DML1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 07:27:37 -0400
Received: from labe.felk.cvut.cz (labe.felk.cvut.cz [147.32.85.34])
	by relay.felk.cvut.cz (8.14.3/8.14.3) with ESMTP id o3DBRQ6F061672
	for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 13:27:26 +0200 (CEST)
	(envelope-from michal.svoboda@agents.felk.cvut.cz)
Received: from [147.32.84.251] (mas16.felk.cvut.cz [147.32.84.166])
	by labe.felk.cvut.cz (8.13.8/8.13.8) with ESMTP id o3DBQQSu097696
	for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 13:26:26 +0200 (CEST)
	(envelope-from michal.svoboda@agents.felk.cvut.cz)
Content-Disposition: inline
In-Reply-To: <1271155163.16881.244.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Pd0ReVV5GZGQvF3a
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Eric Dumazet wrote:
> Why do you use REUSEADDR ? This is doing what is documented.
>=20
>        SO_REUSEADDR
>               Indicates that the rules used in validating addresses  supp=
lied
>               in  a  bind(2) call should allow reuse of local addresses. =
 For
>               AF_INET sockets this means that a socket may bind, except  =
when
>               there is an active listening socket bound to the address.  =
When
>               the listening socket is bound to  INADDR_ANY  with  a  spec=
ific
>               port then it is not possible to bind to this port for any l=
ocal
>               address.  Argument is an integer boolean flag.

I read it 10 times but it doesn't say anything about stealing frames, or
implementation-defined behavior in this case.

> An UDP application wanting a port for its exclusive use dont set
> REUSEADDR, or basically allows anybody to bind an udp socket to same
> port, and potentially steal incoming frames.

That's fair enough, I will talk to the developers of the "very buggy"
applications that use this flag and ask them to reconsider.
=20
> REUSEADDR is usually used when an application has several sockets bound
> to same port, but different IP addresses (or bound to different devices)

I just tried that and you can bind to different IPs without REUSEADDR.


Michal Svoboda


--Pd0ReVV5GZGQvF3a
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkvEVR4ACgkQg/fU9pp1uX6MWQCfd7MIRmSFYUgsYwrnSwjSKoDG
IeYAniiczg2rNR3S2nZSvLQvJu+RGcfe
=scqA
-----END PGP SIGNATURE-----

--Pd0ReVV5GZGQvF3a--
