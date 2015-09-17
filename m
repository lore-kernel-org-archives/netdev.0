From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH next 16/30] ipv6: Only compute net once in
 ip6mr_forward2_finish
Date: Thu, 17 Sep 2015 18:00:56 +0200
Message-ID: <55FAE3B8.6020307@6wind.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
 <1442365458-16349-16-git-send-email-ebiederm@xmission.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35207 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816AbbIQQA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 12:00:59 -0400
Received: by wicge5 with SMTP id ge5so125186731wic.0
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 09:00:57 -0700 (PDT)
In-Reply-To: <1442365458-16349-16-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/09/2015 03:04, Eric W. Biederman a =C3=A9crit :
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>   net/ipv6/ip6mr.c | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
> index e95f6b6281de..3e3085b37a91 100644
> --- a/net/ipv6/ip6mr.c
> +++ b/net/ipv6/ip6mr.c
> @@ -1987,9 +1987,10 @@ int ip6mr_compat_ioctl(struct sock *sk, unsign=
ed int cmd, void __user *arg)
>
>   static inline int ip6mr_forward2_finish(struct sock *sk, struct sk_=
buff *skb)
>   {
> -	IP6_INC_STATS_BH(dev_net(skb_dst(skb)->dev), ip6_dst_idev(skb_dst(s=
kb)),
> +	struct net *net =3D dev_net(skb_dst(skb)->dev);
nit: a blank line is needed after this declaration.

> +	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
>   			 IPSTATS_MIB_OUTFORWDATAGRAMS);
> -	IP6_ADD_STATS_BH(dev_net(skb_dst(skb)->dev), ip6_dst_idev(skb_dst(s=
kb)),
> +	IP6_ADD_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
>   			 IPSTATS_MIB_OUTOCTETS, skb->len);
>   	return dst_output(sk, skb);
>   }
>
