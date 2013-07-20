From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH v3 net-next] ipmr: change the prototype of ip_mr_forward().
Date: Sat, 20 Jul 2013 22:21:49 +0200
Message-ID: <51EAF15D.7080307@6wind.com>
References: <1374322168-5115-1-git-send-email-ramirose@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:41246 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577Ab3GTUVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jul 2013 16:21:54 -0400
Received: by mail-we0-f169.google.com with SMTP id n57so4891161wev.0
        for <netdev@vger.kernel.org>; Sat, 20 Jul 2013 13:21:53 -0700 (PDT)
In-Reply-To: <1374322168-5115-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/07/2013 14:09, Rami Rosen a =C3=A9crit :
> This patch changes the prototpye of the ip_mr_forward() method to ret=
urn void
> instead of int.
>
> The ip_mr_forward() method always returns 0; moreover, the return val=
ue of this
> method is not checked anywhere.
>
> Signed-off-by: Rami Rosen <ramirose@gmail.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

> ---
>   net/ipv4/ipmr.c | 15 +++++++--------
>   1 file changed, 7 insertions(+), 8 deletions(-)
>
> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index 132a096..bacc0bc 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -127,9 +127,9 @@ static struct kmem_cache *mrt_cachep __read_mostl=
y;
>   static struct mr_table *ipmr_new_table(struct net *net, u32 id);
>   static void ipmr_free_table(struct mr_table *mrt);
>
> -static int ip_mr_forward(struct net *net, struct mr_table *mrt,
> -			 struct sk_buff *skb, struct mfc_cache *cache,
> -			 int local);
> +static void ip_mr_forward(struct net *net, struct mr_table *mrt,
> +			  struct sk_buff *skb, struct mfc_cache *cache,
> +			  int local);
>   static int ipmr_cache_report(struct mr_table *mrt,
>   			     struct sk_buff *pkt, vifi_t vifi, int assert);
>   static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff =
*skb,
> @@ -1795,9 +1795,9 @@ static int ipmr_find_vif(struct mr_table *mrt, =
struct net_device *dev)
>
>   /* "local" means that we should preserve one skb (for local deliver=
y) */
>
> -static int ip_mr_forward(struct net *net, struct mr_table *mrt,
> -			 struct sk_buff *skb, struct mfc_cache *cache,
> -			 int local)
> +static void ip_mr_forward(struct net *net, struct mr_table *mrt,
> +			  struct sk_buff *skb, struct mfc_cache *cache,
> +			  int local)
>   {
>   	int psend =3D -1;
>   	int vif, ct;
> @@ -1903,14 +1903,13 @@ last_forward:
>   				ipmr_queue_xmit(net, mrt, skb2, cache, psend);
>   		} else {
>   			ipmr_queue_xmit(net, mrt, skb, cache, psend);
> -			return 0;
> +			return;
>   		}
>   	}
>
>   dont_forward:
>   	if (!local)
>   		kfree_skb(skb);
> -	return 0;
>   }
>
>   static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct =
sk_buff *skb)
>

--=20
Nicolas DICHTEL
6WIND
R&D Engineer

Tel: +33 1 39 30 92 41
=46ax: +33 1 39 30 92 11
nicolas.dichtel@6wind.com
www.6wind.com
www.6windblog.com
Twitter: http://twitter.com/6windsoftware

Ce courriel ainsi que toutes les pi=C3=A8ces jointes, est uniquement de=
stin=C3=A9 =C3=A0 son ou=20
ses destinataires. Il contient des informations confidentielles qui son=
t la=20
propri=C3=A9t=C3=A9 de 6WIND. Toute r=C3=A9v=C3=A9lation, distribution =
ou copie des informations=20
qu'il contient est strictement interdite. Si vous avez re=C3=A7u ce mes=
sage par=20
erreur, veuillez imm=C3=A9diatement le signaler =C3=A0 l'=C3=A9metteur =
et d=C3=A9truire toutes les=20
donn=C3=A9es re=C3=A7ues.

This e-mail message, including any attachments, is for the sole use of =
the=20
intended recipient(s) and contains information that is confidential and=
=20
proprietary to 6WIND. All unauthorized review, use, disclosure or distr=
ibution=20
is prohibited. If you are not the intended recipient, please contact th=
e sender=20
by reply e-mail and destroy all copies of the original message.
