From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ipfrag : frag_kfree_skb() cleanup
Date: Mon, 14 Jun 2010 16:20:12 +0200
Message-ID: <1276525212.2478.93.camel@edumazet-laptop>
References: <1276507363.2478.43.camel@edumazet-laptop>
	 <4C163643.1080906@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:58897 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754168Ab0FNOUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 10:20:20 -0400
In-Reply-To: <4C163643.1080906@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 juin 2010 =C3=A0 22:01 +0800, Shan Wei a =C3=A9crit :
> Eric Dumazet wrote, at 06/14/2010 05:22 PM:
> > Third param (work) is unused, remove it.
> >=20
> > Remove __inline__ and inline qualifiers.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> we also need to fix IPv6 netfilter.
>=20

well, 'fix' is not appropriate, there is no bug ;)

> [PATCH 2/2] netfilter: defrag: kill unused work parameter of frag_kfr=
ee_skb()
>=20
> The parameter (work) is unused, remove it.
> Reported from Eric Dumazet.
>=20
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

> ---
>  net/ipv6/netfilter/nf_conntrack_reasm.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
>=20
> diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfi=
lter/nf_conntrack_reasm.c
> index bc5b86d..9254008 100644
> --- a/net/ipv6/netfilter/nf_conntrack_reasm.c
> +++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
> @@ -114,10 +114,8 @@ static void nf_skb_free(struct sk_buff *skb)
>  }
> =20
>  /* Memory Tracking Functions. */
> -static inline void frag_kfree_skb(struct sk_buff *skb, unsigned int =
*work)
> +static void frag_kfree_skb(struct sk_buff *skb)
>  {
> -	if (work)
> -		*work -=3D skb->truesize;
>  	atomic_sub(skb->truesize, &nf_init_frags.mem);
>  	nf_skb_free(skb);
>  	kfree_skb(skb);
> @@ -335,7 +333,7 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_q=
ueue *fq, struct sk_buff *skb,
>  				fq->q.fragments =3D next;
> =20
>  			fq->q.meat -=3D free_it->len;
> -			frag_kfree_skb(free_it, NULL);
> +			frag_kfree_skb(free_it);
>  		}
>  	}
> =20


