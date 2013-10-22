From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH net] netpoll: linearize skb before accessing its data
Date: Tue, 22 Oct 2013 08:37:14 +0200
Message-ID: <20131022063714.GI1544@neomailbox.net>
References: <1382391080-1607-1-git-send-email-antonio@meshcoding.com>
 <20131021.182319.625146263287554088.davem@davemloft.net>
 <20131022060635.GF1544@neomailbox.net>
 <20131022.022525.2068838304168924147.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="zgY/UHCnsaNnNXRx"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:34478 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166Ab3JVGhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 02:37:52 -0400
Content-Disposition: inline
In-Reply-To: <20131022.022525.2068838304168924147.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--zgY/UHCnsaNnNXRx
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 22, 2013 at 02:25:25AM -0400, David Miller wrote:
> From: Antonio Quartulli <antonio@meshcoding.com>
> Date: Tue, 22 Oct 2013 08:06:35 +0200
>=20
> > But rx_hook() does not receive any skb:
> >=20
> > 609                 np->rx_hook(np, ntohs(uh->source),
> > 610                                (char *)(uh+1),
> > 611                                ulen - sizeof(struct udphdr));
> >=20
> > it just receives a pointer to the data and can't do anything to make it=
 linear.
> > (uh is a pointer to the udp header). Am I missing something?
>=20
> Then this hook's API needs to be fixed, it's completely broken.
>=20
> Make it pass the SKB and the appropriate offset (from skb->data) in
> bytes.
>=20

Ok I will do that. But I think this API change must go into net-next, right?
Otherwise we would break every existing user.

What about resending this patch to net (after having removed the pskb_may_p=
ull()
as pointed out by Eric) and then fixing the API in net-next?

--=20
Antonio Quartulli

--zgY/UHCnsaNnNXRx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSZh0aAAoJEADl0hg6qKeOYD4P/2ogozc83oiWXvnGzS7Cigoz
IPmB020/k3aHWjgyaHCtzm+QdULS9POZZZh3iQ0H4TB5ZOew2VEW7P7u/3Vzo8yX
bpP3jNj0siZtR+Q9Kj0BvJVZRv6kF8ZVxL/VfatjOGKvavQo52vYTTmJ5aiaShXh
qCkH3Slts5ddoel4BZoynGdVKHuLk7c+j0Q+t4XxYNUWw0eN/AxFKCcPY9J4qDwI
kbDgSMptfzfVqcn5SQEHnrLU89Wtu/ryzUfP5Z9JTitmI0Wt673T+kc6HU1lzzRG
BH3NTFimKUx+c4EWrza706M84oZ680H4IQN2x9+FKJABGYI4eM+YXMFfzqiklN6s
3Q9wanqWZB1qYoQ7G3vmmSt9P63EgQph9nfhgILOFod+fcAW3SvhLGGnqHHmlP6+
Ng3pkVlsq16srttPxp8MiuA9R+PEwCLUJKQcQH5+MfdPdcTZD0Xsxp63jqsogKn/
+up0qUOoMJ4S9HFTiGRRerNGCSqj74qxvZN5xnxWHCpYqFkF3BTHNtnK2ZMlZpNC
h34c6IbHJ5T6EBhPIxpD0MtYXHXPOX7sd45+djtPu7jOkVJuelD1RhZzJlp+McQc
fHX7Pn/J0tTsByWNRp3OfdjKMed2T4UujcY12nrje2VCrwF/+dkk/l6lSIBllhTk
ZVmZBA9H1tK0uriIfxEq
=3S8R
-----END PGP SIGNATURE-----

--zgY/UHCnsaNnNXRx--
