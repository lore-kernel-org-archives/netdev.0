From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH next 22/30] ipv6: Cache net in ip6_output
Date: Thu, 17 Sep 2015 18:06:02 +0200
Message-ID: <55FAE4EA.9060402@6wind.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
 <1442365458-16349-22-git-send-email-ebiederm@xmission.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1442365458-16349-22-git-send-email-ebiederm@xmission.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 16/09/2015 03:04, Eric W. Biederman a =C3=A9crit :
> Keep net in a local variable so I can use it in NF_HOOK_COND
> when I pass struct net to all of the netfilter hooks.
>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>   net/ipv6/ip6_output.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 12d0166a64cd..8cab909b181e 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -135,9 +135,9 @@ int ip6_output(struct sock *sk, struct sk_buff *s=
kb)
>   {
>   	struct net_device *dev =3D skb_dst(skb)->dev;
>   	struct inet6_dev *idev =3D ip6_dst_idev(skb_dst(skb));
> +	struct net *net =3D dev_net(dev);
nit: same here for the blank line.

>   	if (unlikely(idev->cnf.disable_ipv6)) {
> -		IP6_INC_STATS(dev_net(dev), idev,
> -			      IPSTATS_MIB_OUTDISCARDS);
> +		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
>   		kfree_skb(skb);
>   		return 0;
>   	}
>

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
