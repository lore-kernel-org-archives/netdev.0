From: Noah Meyerhans <frodo@morgul.net>
Subject: Re: [PATCH] bridge: fix forwarding of IPv6
Date: Fri, 13 May 2011 14:00:15 -0700
Message-ID: <20110513210015.GV6397@morgul.net>
References: <20110506201234.6297.70279.reportbug@ip6-localhost> <1304995124.4065.157.camel@localhost> <20110510043833.GG6397@morgul.net> <1305031369.4065.259.camel@localhost> <20110510180540.GI6397@morgul.net> <20110510151100.52a9f8fa@nehalam> <20110510233540.GJ6397@morgul.net> <20110513125314.66861b31@nehalam>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2RPSo2VWgDbGU+zh"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	bridge@lists.linux-foundation.org, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.morgul.net ([128.31.0.48]:46841 "EHLO minas.morgul.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756590Ab1EMVAZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2011 17:00:25 -0400
Content-Disposition: inline
In-Reply-To: <20110513125314.66861b31@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--2RPSo2VWgDbGU+zh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 13, 2011 at 12:53:14PM -0700, Stephen Hemminger wrote:
> The commit 6b1e960fdbd75dcd9bcc3ba5ff8898ff1ad30b6e
>     bridge: Reset IPCB when entering IP stack on NF_FORWARD
> broke forwarding of IPV6 packets in bridge because it would
> call bp_parse_ip_options with an IPV6 packet.
>=20
> Reported-by: Noah Meyerhans <noahm@debian.org>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
> Patch against net-next-2.6 but must be applied to net-2.6
> and stable as well
>=20
> --- a/net/bridge/br_netfilter.c	2011-05-13 12:37:30.289646958 -0700
> +++ b/net/bridge/br_netfilter.c	2011-05-13 12:38:07.820333938 -0700
> @@ -737,7 +737,7 @@ static unsigned int br_nf_forward_ip(uns
>  		nf_bridge->mask |=3D BRNF_PKT_TYPE;
>  	}
> =20
> -	if (br_parse_ip_options(skb))
> +	if (pf =3D=3D PF_INET && br_parse_ip_options(skb))
>  		return NF_DROP;
> =20
>  	/* The physdev module checks on this */
>=20

I can confirm that this patch fixes the behavior I've been seeing in the
stable-2.6.38.y tree.  Thank you, Stephen!

noah



--2RPSo2VWgDbGU+zh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQFNzZveYrVLjBFATsMRAqZSAJ9eI6PteR7PUswZzyBjTPPlZwqpVACfZoSE
YaFcCqSyLZx6AUTTCzGhIU0=
=2WQK
-----END PGP SIGNATURE-----

--2RPSo2VWgDbGU+zh--
