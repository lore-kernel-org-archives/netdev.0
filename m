From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 001/001] QoS and/or fair queueing: Stateless NAT BUG
Date: Fri, 09 Jul 2010 19:54:23 +0200
Message-ID: <1278698063.2696.61.camel@edumazet-laptop>
References: <201007091937.17349.rpartearroyo@albentia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Iratxo Pichel Ortiz <ipichel@albentia.com>,
	Noelia =?ISO-8859-1?Q?Mor=F3n?= <nmoron@albentia.com>,
	netdev <netdev@vger.kernel.org>
To: Rodrigo Partearroyo =?ISO-8859-1?Q?Gonz=E1lez?=
	<rpartearroyo@albentia.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201007091937.17349.rpartearroyo@albentia.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 09 juillet 2010 =C3=A0 19:37 +0200, Rodrigo Partearroyo Gon=
z=C3=A1lez
a =C3=A9crit :
> Hi all,
> I have been testing Stateless NAT and found that ICMP packets with le=
ngth
> less than 20 bytes were not correctly NAT'ed. I have found a BUG that
> makes taking into account IP header length twice, so ICMP packets sma=
ller
> than 20 bytes were being dropped.
>=20
> Proposed formal patch is below, as suggested by Eric Dumazet, thanks.
> It is taken from 2.6.34.1 stable version.
>=20
> Signed-off-by: Rodrigo Partearroyo Gonz=C3=A1lez <rpartearroyo@albent=
ia.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

> ---
> diff -uprN a/net/sched/act_nat.c b/net/sched/act_nat.c
> --- a/net/sched/act_nat.c	2010-07-09 18:25:18.000000000 +0200
> +++ b/net/sched/act_nat.c	2010-07-09 18:26:16.000000000 +0200
> @@ -202,7 +202,7 @@ static int tcf_nat(struct sk_buff *skb,=20
>  	{
>  		struct icmphdr *icmph;
> =20
> -		if (!pskb_may_pull(skb, ihl + sizeof(*icmph) + sizeof(*iph)))
> +		if (!pskb_may_pull(skb, ihl + sizeof(*icmph)))
>  			goto drop;
> =20
>  		icmph =3D (void *)(skb_network_header(skb) + ihl);
> @@ -223,7 +223,7 @@ static int tcf_nat(struct sk_buff *skb,=20
> =20
>  		if (skb_cloned(skb) &&
>  		    !skb_clone_writable(skb,
> -					ihl + sizeof(*icmph) + sizeof(*iph)) &&
> +					ihl + sizeof(*icmph)) &&
>  		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
>  			goto drop;
>=20
