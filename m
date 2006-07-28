From: Hugo Santos <hsantos@av.it.pt>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Fri, 28 Jul 2006 09:34:33 +0100
Message-ID: <20060728083433.GG29313@innerghost.net>
References: <20060728014528.GB29313@innerghost.net> <20060727.192743.39159331.davem@davemloft.net> <20060728031322.GE29313@innerghost.net> <20060727.202044.85689055.davem@davemloft.net> <20060728033132.GF29313@innerghost.net> <20060727210738.36f33436@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4C6bbPZ6c/S1npyF"
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	kazunori@miyazawa.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:28312 "EHLO av.it.pt")
	by vger.kernel.org with ESMTP id S1751980AbWG1Ieg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 04:34:36 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060727210738.36f33436@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--4C6bbPZ6c/S1npyF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

> A couple of basic questions:
> 1. Can we just proceed assuming it is non-secure until a later time when
>    the certificate path is established?

   This is not something which is described in the standard. In fact,
 processing the RA without a certificate path to the router already
 assumes the host is configured to so do (assuming unverified messages
 are treated as normal non-secure ones). Treating it as non-secure would
 allow an attacker to temporarily receive packets from the host if it
 has no secure router to be used (in the same or other interfaces).
 This may allow it to retrieve some of the user's info (think web-login
 portal) and it just has to be on-link (typical NDP attack). A solution
 would be not to assume it is non-secure, but instead cache or drop the
 RA and initiate the process to obtain a certificate path. This however
 does not allow the kind of behaviour that Dave described in one of is
 earlier e-mails, where packets are processed in order.

   Also, the host cache needs to hold X.509v3 certificates, and even if
 a lighter crypto-hash based check is available (if CGAs are used as
 well, to make sure the packets come from the packet's source address),
 hosts will end up having to perform RSA signature checks.

> 2. What if user process dies? or gets overwhelmed?
>    One of the assumptions of the any well designed kernel is that the system should never
>    hang because some user application died or waited for ever.

   Of course that this is a real problem. However, if the control daemon
 dies the kernel won't die. Depending on the implementation -- you might
 temporarily get out of addresses, if the addresses are flushed when the
 control daemon dies, etc. But, just like a routing daemon is critical
 to a router, this control application would also be critical to the
 host's connectivity. And if it dies, it needs to be restarted. The
 application might be itself complex, but in the end we moved this
 complexity away from the kernel.

   Hugo

--4C6bbPZ6c/S1npyF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFEycwZ7asb/itUNKwRAiSGAJ49cYP8Ip0R+ZDeHTLm6SsZrskxxwCfSiBA
wE9yHdxhRyd0Y/owJq4dKOY=
=Jbz2
-----END PGP SIGNATURE-----

--4C6bbPZ6c/S1npyF--
