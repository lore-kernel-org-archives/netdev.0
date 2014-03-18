From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 6/6] net: Free skbs from irqs when possible.
Date: Tue, 18 Mar 2014 13:30:07 +0000
Message-ID: <1395149407.22343.8.camel@deadeye.wl.decadent.org.uk>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	 <87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
	 <20140317.154916.2276987764507311378.davem@davemloft.net>
	 <87iorcgh5d.fsf_-_@xmission.com> <87fvmgf2c7.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-xuY7SdJjaVDfan7nwVE9"
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52093 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754380AbaCRNaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 09:30:22 -0400
In-Reply-To: <87fvmgf2c7.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xuY7SdJjaVDfan7nwVE9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-03-17 at 23:27 -0700, Eric W. Biederman wrote:
[...]
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -554,14 +554,21 @@ static void kfree_skbmem(struct sk_buff *skb)
> =20
>  static void skb_release_head_state(struct sk_buff *skb)
>  {
> +	WARN_ONCE(in_irq() && !skb_irq_freeable(skb),
> +		  "%s called from irq! sp %d nfct %d frag_list %d %pF dst %lx",
> +		  __func__,
> +		  IS_ENABLED(CONFIG_XFRM) ? !!skb->sp : 0,
> +		  IS_ENABLED(CONFIG_NF_CONNTRACK) ? !!skb->nfct : 0,
[...]

This is a syntax error if CONFIG_XFRM or CONFIG_NF_CONNTRACK is
disabled; you have to use #ifdef's.

Ben.

--=20
Ben Hutchings
Experience is directly proportional to the value of equipment destroyed.
                                                         - Carolyn Scheppne=
r

--=-xuY7SdJjaVDfan7nwVE9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUyhKX+e/yOyVhhEJAQpS7hAAxZmRwKHABQf8gc2GfNN244VVUZgDTLFw
RB9MQ/NYsJpnR8JLQMzARBHwZJWSkSu4L8hx+Jz9dOiQFRIv41p7vpasYzmNF5ml
U4V9GWfwbi1x7ZNEtgdcvz3ttqHny2zrkqfD4cQgX1X29co8Xu2yYmZmOJYhv7zE
or5yCmxAfgxPpAEW7s0jZtfm5pJap10XfZnqFlN09gRY/i+ScnFI+KsoxGGh0FDd
nFI579mvapjBGEuUmYFjKZ218PgETML2haf6xxmR0peAm3GDCZixrT3dk0UfXmkA
4hXKblwvdLDnvMnYK2HmYy8IYPOaB2lDbEV61m3biifVuxbh9gHgJj6XRdlptRBt
SKIE5lnK6kNuPFTWek5Z1dQlAf09MfKutLBda1jBmnZFXilaFJjzRcQ/S5bcCxb2
Bjzo1L62BenHID4tzgkmJguIDCKPL/Qkv43dVdv+keJesa2DWnil9ktJ+idVVvE5
Qkr4y9fPftkRSdro7OEeodtLViMI+916CRKwbqM1IGo63cJ/p4sRD4JPofNQdE8/
23iGYDrll6Ms0S+m3vuFTNVJs4vtF6KAfBI2Mk879NbYDX0bAapfF7jLFCHbrvtl
fHUjmXVhEFm6C/fNkGN1qe9j9Yr+UBhLjaBmZ29WibD3G2hd3rp6s4K2yUvAzL5b
RIsO9D8b4nM=
=xLoI
-----END PGP SIGNATURE-----

--=-xuY7SdJjaVDfan7nwVE9--
