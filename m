From: Hugo Santos <hsantos@av.it.pt>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Fri, 28 Jul 2006 04:31:32 +0100
Message-ID: <20060728033132.GF29313@innerghost.net>
References: <20060728014528.GB29313@innerghost.net> <20060727.192743.39159331.davem@davemloft.net> <20060728031322.GE29313@innerghost.net> <20060727.202044.85689055.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2E/hm+v6kSLEYT3h"
Cc: herbert@gondor.apana.org.au, kazunori@miyazawa.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:40086 "EHLO av.it.pt")
	by vger.kernel.org with ESMTP id S1751075AbWG1Dbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 23:31:33 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060727.202044.85689055.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--2E/hm+v6kSLEYT3h
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 27, 2006 at 08:20:44PM -0700, David Miller wrote:
>=20
> Now, if you're saying that, in response to a NDISC packet, we might
> have to go out and obtain the certificate, before we can process
> the NDISC packet.  This is a different issue.  Is that how this
> secure NDISC works?  Or does the system obtain all the certificates
> first, by some other means, and then either it can certify an NDISC
> frame immediately or it can't?

   It might happen that the host must ask the router for a Certification
 Path by receiving a Router Advertisement. More specifically, RFC 3971
 Section 6.4.6. 'Processing Rules for Hosts' states the following:

      The host SHOULD retrieve a certification path when a Router
      Advertisement has been received with a public key that is not
      available from a certificate in the hosts' cache, or when there is
      no certification path to one of the host's trust anchors.  In
      these situations, the host MAY send a Certification Path
      Solicitation message to retrieve the path.  If there is no
      response within CPS_RETRY seconds, the message should be retried.
      The wait interval for each subsequent retransmission MUST
      exponentially increase, doubling each time.  If there is no
      response after CPS_RETRY_MAX seconds, the host abandons the
      certification path retrieval process. (...)

   If no certification path is established, the RA must be treated as
 unsecure. Secure prefixes are given preference over non-secure ones so
 it might cause problems.

   Hugo

--2E/hm+v6kSLEYT3h
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFEyYUU7asb/itUNKwRAkjeAKDSeKvJDp8PYkFB19HrKXrgQ5kZnACeJr4H
il2sl7VLMFfpy7ZUrAU+qdg=
=RQlF
-----END PGP SIGNATURE-----

--2E/hm+v6kSLEYT3h--
