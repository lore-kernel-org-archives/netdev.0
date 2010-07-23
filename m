From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] iptables: use skb->len for accounting
Date: Fri, 23 Jul 2010 08:29:01 +0200
Message-ID: <1279866541.2482.79.camel@edumazet-laptop>
References: <1279856088-9004-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279856088-9004-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 23 juillet 2010 =C3=A0 11:34 +0800, Changli Gao a =C3=A9cri=
t :
> iptables: use skb->len for accounting
>=20
> use skb->len for accounting as xt_quota does.
>=20

Why ?

This is a gratuitous change, unless you have very strong arguments.

xt_quota is an exception, dont change all others because of it !

It is about actual data on wire, including overhead (excess bytes after
IP frame if any).

But IP tables accounting is about IP only.

> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
>  net/ipv4/netfilter/ip_tables.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_t=
ables.c
> index b38c118..3c584a6 100644
> --- a/net/ipv4/netfilter/ip_tables.c
> +++ b/net/ipv4/netfilter/ip_tables.c
> @@ -364,7 +364,7 @@ ipt_do_table(struct sk_buff *skb,
>  				goto no_match;
>  		}
> =20
> -		ADD_COUNTER(e->counters, ntohs(ip->tot_len), 1);
> +		ADD_COUNTER(e->counters, skb->len, 1);
> =20
>  		t =3D ipt_get_target(e);
>  		IP_NF_ASSERT(t->u.kernel.target);
> --



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
