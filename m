From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BTW
Date: Wed, 27 Oct 2004 18:28:22 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CMjAM-0002aJ-00@gondolin.me.apana.org.au>
References: <20041027074307.GT18934@sunbeam.de.gnumonks.org>
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: laforge@netfilter.org (Harald Welte)
In-Reply-To: <20041027074307.GT18934@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Harald Welte <laforge@netfilter.org> wrote:
>
> +++ linux-2.6.9-bk7-netlink_f_multi/net/ipv4/tcp_diag.c 2004-10-22 19:50:43.000000000 +0200
> @@ -108,7 +108,7 @@
> }
> 
> static int tcpdiag_fill(struct sk_buff *skb, struct sock *sk,
> -                       int ext, u32 pid, u32 seq)
> +                       int ext, u32 pid, u32 seq, u16 nlmsg_flags)
> {
>        struct inet_opt *inet = inet_sk(sk);
>        struct tcp_opt *tp = tcp_sk(sk);
> @@ -235,6 +235,7 @@
>        }
> 
>        nlh->nlmsg_len = skb->tail - b;
> +       nlh->nlmsg_flags = nlmsg_flags;

This doesn't set it for the tw sockets.  So just set it at the top
of the function instead.

The rest of the tcp_diag stuff looks good.

> @@ -351,7 +351,10 @@
>        nlh = NLMSG_PUT(skb, NETLINK_CB(in_skb).pid,
>                        sp->nlmsg_seq,
>                        XFRM_MSG_NEWSA, sizeof(*p));
> -       nlh->nlmsg_flags = 0;
> +       if (NETLINK_CB(in_skb).pid && (count || sp->this_idx))
> +               nlh->nlmsg_flags = NLM_F_MULTI;
> +       else
> +               nlh->nlmsg_flags = 0;

Yuck.  Please put this into xfrm_dump_info.

And it would be good to fix the other dumper in this file (xfrm_dump_policy)
as well.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
