From: Hugo Santos <hsantos@av.it.pt>
Subject: Re: [RFC] Mobile IPv6 introduction
Date: Wed, 2 Aug 2006 12:03:38 +0100
Message-ID: <20060802110338.GO8334@innerghost.net>
References: <44CB2914.9010803@linux-ipv6.org> <20060729141244.GJ8334@innerghost.net> <20060801.173535.38709014.davem@davemloft.net> <20060802005849.GK8334@innerghost.net> <44D05B39.5080608@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xFawzEZLoq+g1Byu"
Cc: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:47841 "EHLO av.it.pt")
	by vger.kernel.org with ESMTP id S1750728AbWHBLDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 07:03:40 -0400
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
Content-Disposition: inline
In-Reply-To: <44D05B39.5080608@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--xFawzEZLoq+g1Byu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Ville,

On Wed, Aug 02, 2006 at 10:58:49AM +0300, Ville Nuorvala wrote:
> To name just one issue: the chicken and egg problem of source address
> selection and source address based routing. I solved this problem by
> letting policy rules (with a source prefix) add additional constraints
> to the address selection. This did however mean the source address
> selection had to be moved inside the routing code.

   To tell you the truth i don't know what MIPL does in terms of policy
 management. In my implementation, all routing policies go into
 Subtrees without any kind of extra routing tables. I also had the
 problem you describe, but i opted for what i think is a simpler
 solution:

   - Access router default routes are installed with a source-address,
     the address that was generated from the announced prefix (which to
     be fair degenerates to several entries if a single router announces
     multiple prefixes). This is based on the assumption that access
     routers do perform source-based ingress filtering so you may only
     use a particular access router for global connectivity using a
     particular address.
   - The default home route is installed without a source-address for
     the "default" Home address (i may have several).

   This means Linux's source address selection works without
 modifications: if no address is specified, it will pick the default
 home route and then the Home address (which has a preference as well).
 In this sense, subtrees have worked fine for me.

> But route optimization is just one form of packet transform; it just
> adds a Routing Header type 2 and/or Home Address Option Destination
> Header to the outgoing packet. Isn't xfrm just the right place for this?
>=20
> You are right that we (HUT and USAGI) have mostly just looked at the
> xfrm framework from a MIPv6+IPsec perspective, but even this has helped
> us pinpoint several shortcomings in the current only IPsec specific
> framework.

   XFRM is indeed the right place for this; i just would rather not have
 the mode exposed and prefer wrapping any mode-specific stuff into
 optional callbacks. It might not be as performant but would allow
 adding new modes more easily.

   Hugo

--xFawzEZLoq+g1Byu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFE0IaK7asb/itUNKwRAnFYAJ9raLBwSNYt/7j4AFwCROnOpxAtRQCeJ+dJ
u1zm0M2xZoZLlCAKNUIfKaY=
=ZWCL
-----END PGP SIGNATURE-----

--xFawzEZLoq+g1Byu--
