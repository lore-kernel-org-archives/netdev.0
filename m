From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net-next: make sock diag per-namespace
Date: Mon, 16 Jul 2012 14:32:25 +0200
Message-ID: <1342441945.23494.23.camel@edumazet-glaptop>
References: <1342440849-1757320-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Vagin <avagin@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1342440849-1757320-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-07-16 at 16:14 +0400, Andrew Vagin wrote:
> Before this patch sock_diag works for init_net only and dumps
> information about sockets from all namespaces.

...

> diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
> index a7f86a3..52f42f9 100644
> --- a/net/ipv4/udp_diag.c
> +++ b/net/ipv4/udp_diag.c
> @@ -34,6 +34,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
>  	int err = -EINVAL;
>  	struct sock *sk;
>  	struct sk_buff *rep;
> +	struct net *net = sock_net(in_skb->sk);
>  
>  	if (req->sdiag_family == AF_INET)
>  		sk = __udp4_lib_lookup(&init_net,

It seems you didnt fix udp_dump_one() correctly, since it
still mentions &init_net

> @@ -75,7 +76,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
>  		kfree_skb(rep);
>  		goto out;
>  	}
> -	err = netlink_unicast(sock_diag_nlsk, rep, NETLINK_CB(in_skb).pid,
> +	err = netlink_unicast(net->diag_nlsk, rep, NETLINK_CB(in_skb).pid,
>  			      MSG_DONTWAIT);
>  	if (err > 0)
>  		err = 0;

udp_dump() also needs some care ?
