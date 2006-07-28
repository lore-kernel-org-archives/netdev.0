From: Hugo Santos <hsantos@av.it.pt>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Fri, 28 Jul 2006 04:13:22 +0100
Message-ID: <20060728031322.GE29313@innerghost.net>
References: <E1G6Fic-0005py-00@gondolin.me.apana.org.au> <20060727.183415.104032934.davem@davemloft.net> <20060728014528.GB29313@innerghost.net> <20060727.192743.39159331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="27ZtN5FSuKKSZcBU"
Cc: herbert@gondor.apana.org.au, kazunori@miyazawa.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:32918 "EHLO av.it.pt")
	by vger.kernel.org with ESMTP id S1751068AbWG1DNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 23:13:24 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060727.192743.39159331.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--27ZtN5FSuKKSZcBU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, Jul 27, 2006 at 07:27:43PM -0700, David Miller wrote:
>=20
> Just like a TCP connection, packets cause state transitions.
> And it is reasonable to expect that after a state transition,
> the effects can be visible by subsequent packets.

   Certainly, control packets cause state transitions. TCP is a mixed
 bag. I think the question here is whether we can afford a stack where
 the data path is fully synchronous with the control path -- considering
 the amount of "time" required by a state transition (and other burdens
 you've identified). It might not pose a problem using the current
 signalling, but as an example, if we consider SEcure Neighbor Discovery
 (SEND, RFC 3971), validating a secure prefix to derive an address from,
 involves checking certificate signatures (besides the
 certificate-obtaining procedure); a process which may take some time.

   I believe it is reasonable to be synchronous within certain limits,
 specifically when the impact is local; for instance queueing outgoing
 packets during neighbor resolution (which is something some network
 stacks don't do actually). However when we consider something as global
 to the stack as configuring an address, being synchronous is expensive.

   I understand that any kind of impact should be well thought of, and
 adding new interfaces and behaviour to the kernel just adds to complex-
 ity and maintenance hell. But in this case, i think that adding a bit
 of additional complexity to the kernel would save us from a bunch of
 extra complexity in the long run associated with supporting these new
 protocols; besides helping the development.

   Hugo

--27ZtN5FSuKKSZcBU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFEyYDS7asb/itUNKwRAgQsAKDJaXYe3uj1U63Sf7sCFM56fRIbewCfaPFv
zpJFVvZVJuQ2SSRhfINX26Y=
=qSh4
-----END PGP SIGNATURE-----

--27ZtN5FSuKKSZcBU--
