From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH net-next] ipv6: almost identical frag hashing funcs
	combined
Date: Tue, 30 Sep 2008 22:18:38 -0300
Message-ID: <20081001011838.GB970@ghostprotocols.net>
References: <Pine.LNX.4.64.0810010146001.27688@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60879 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751489AbYJABUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2008 21:20:41 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0810010146001.27688@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Oct 01, 2008 at 01:57:47AM +0300, Ilpo J=E4rvinen escreveu:
>=20
> $ diff-funcs ip6qhashfn reassembly.c netfilter/nf_conntrack_reasm.c
>  --- reassembly.c:ip6qhashfn()
>  +++ netfilter/nf_conntrack_reasm.c:ip6qhashfn()
> @@ -1,5 +1,5 @@
> -static unsigned int ip6qhashfn(__be32 id, struct in6_addr *saddr,
> -			       struct in6_addr *daddr)
> +static unsigned int ip6qhashfn(__be32 id, const struct in6_addr *sad=
dr,
> +			       const struct in6_addr *daddr)
>  {
>  	u32 a, b, c;
>=20
> @@ -9,7 +9,7 @@
>=20
>  	a +=3D JHASH_GOLDEN_RATIO;
>  	b +=3D JHASH_GOLDEN_RATIO;
> -	c +=3D ip6_frags.rnd;
> +	c +=3D nf_frags.rnd;
>  	__jhash_mix(a, b, c);
>=20
>  	a +=3D (__force u32)saddr->s6_addr32[3];
>=20
> And codiff xx.o.old xx.o.new:
>=20
> net/ipv6/netfilter/nf_conntrack_reasm.c:
>   ip6qhashfn         | -512
>   nf_hashfn          |   +6
>   nf_ct_frag6_gather |  +36
>  3 functions changed, 42 bytes added, 512 bytes removed, diff: -470
> net/ipv6/reassembly.c:
>   ip6qhashfn    | -512
>   ip6_hashfn    |   +7
>   ipv6_frag_rcv |  +89
>  3 functions changed, 96 bytes added, 512 bytes removed, diff: -416
>=20
> net/ipv6/reassembly.c:
>   inet6_hash_frag | +510
>  1 function changed, 510 bytes added, diff: +510
>=20
> Total: -376
>=20
> Compile tested.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Good stuff, I wonder if you can spot possible candidades by sorting by
function size... Or perhaps by function signature... perhaps a new dwar=
f
that looks just at the parameter types, ordering by type name, and
reducing typedefs :-)

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

- Arnaldo
