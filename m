From: Hugo Santos <hsantos@av.it.pt>
Subject: Re: [RFC] [IPV6] ADDRCONF: Lifetime handling fixes
Date: Thu, 27 Jul 2006 11:28:02 +0100
Message-ID: <20060727102802.GM6026@innerghost.net>
References: <20060727.185726.133626295.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="WuedheRyq6FDfQ9j"
Cc: davem@davemloft.net, vnuorval@tcs.hut.fi, anttit@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:22146 "EHLO av.it.pt")
	by vger.kernel.org with ESMTP id S1751021AbWG0K2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 06:28:05 -0400
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20060727.185726.133626295.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--WuedheRyq6FDfQ9j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

>  static int
> +inet6_addr_modify(int ifindex, struct in6_addr *pfx,
> +		  __u32 prefered_lft, __u32 valid_lft)
> +{

   ...

> +	ifp = ipv6_get_ifaddr(pfx, dev, 1);
> +	if (ifp == NULL)
> +		return -ENOENT;
> +
> +	if (!valid_lft || (prefered_lft > valid_lft))
> +		return -EINVAL;
                ^^^^^^^^^^^^^^^

   Unreleased ifp? This test should go before ipv6_get_ifaddr.

   Hugo

--WuedheRyq6FDfQ9j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFEyJUy7asb/itUNKwRAhaAAKDNqqqwgE65KKQP8gQdHPBV9uBxOQCbBjLh
MAMQj6rlZITXF2ms3WEjFls=
=VdVB
-----END PGP SIGNATURE-----

--WuedheRyq6FDfQ9j--
