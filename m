From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] act_nat: not all of the ICMP packets need an IP header
 payload
Date: Sat, 10 Jul 2010 08:22:33 +0200
Message-ID: <1278742953.2538.24.camel@edumazet-laptop>
References: <1278725605-28598-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Rodrigo Partearroyo =?ISO-8859-1?Q?Gonz=E1lez?=
	<rpartearroyo@albentia.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Iratxo Pichel Ortiz <ipichel@albentia.com>,
	Noelia =?ISO-8859-1?Q?Mor=F3n?= <nmoron@albentia.com>,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65249 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178Ab0GJGWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 02:22:37 -0400
Received: by wwb24 with SMTP id 24so5603677wwb.1
        for <netdev@vger.kernel.org>; Fri, 09 Jul 2010 23:22:36 -0700 (PDT)
In-Reply-To: <1278725605-28598-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 10 juillet 2010 =C3=A0 09:33 +0800, Changli Gao a =C3=A9crit =
:
> act_nat: not all of the ICMP packets need an IP header payload
>=20
> not all of the ICMP packets need an IP header payload, so we check th=
e length
> of the skbs only when the packets should have an IP header payload.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
>  net/sched/act_nat.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
> index 0be49a4..24e614c 100644
> --- a/net/sched/act_nat.c
> +++ b/net/sched/act_nat.c
> @@ -205,7 +205,7 @@ static int tcf_nat(struct sk_buff *skb, struct tc=
_action *a,
>  	{
>  		struct icmphdr *icmph;
> =20
> -		if (!pskb_may_pull(skb, ihl + sizeof(*icmph) + sizeof(*iph)))
> +		if (!pskb_may_pull(skb, ihl + sizeof(*icmph)))
>  			goto drop;
> =20
>  		icmph =3D (void *)(skb_network_header(skb) + ihl);
> @@ -215,6 +215,9 @@ static int tcf_nat(struct sk_buff *skb, struct tc=
_action *a,
>  		    (icmph->type !=3D ICMP_PARAMETERPROB))
>  			break;
> =20
> +		if (!pskb_may_pull(skb, ihl + sizeof(*icmph) + sizeof(*iph)))
> +			goto drop;
> +
>  		iph =3D (void *)(icmph + 1);
>  		if (egress)
>  			addr =3D iph->daddr;

Changli, this patch has no attribution.

Rodrigo spent lot of time to find the problem and is willing to fix it.

Could you please give a chance to Rodrigo to complete its first kernel
patch ?

Thanks


