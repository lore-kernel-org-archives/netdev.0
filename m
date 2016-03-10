From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH next v2 6/7] xfrm: Use l3_dev for xfrm policy checks.
Date: Thu, 10 Mar 2016 10:48:08 +0100
Message-ID: <56E142D8.9080308@6wind.com>
References: <1457560212-13289-1-git-send-email-mahesh@bandewar.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>, Tim Hockin <thockin@google.com>,
	Alex Pollitt <alex.pollitt@metaswitch.com>,
	Matthew Dupre <matthew.dupre@metaswitch.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Mahesh Bandewar <mahesh@bandewar.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38591 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754555AbcCJJsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 04:48:11 -0500
Received: by mail-wm0-f42.google.com with SMTP id l68so20755221wml.1
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2016 01:48:10 -0800 (PST)
In-Reply-To: <1457560212-13289-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+ Steffen

Le 09/03/2016 22:50, Mahesh Bandewar a =C3=A9crit :
> From: Mahesh Bandewar <maheshb@google.com>
>
> IPsec, whether it's tunnel mode or transport mode, is still a
> function of L3 so all the decisions should be based on the L3
> device.
>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> CC: Eric Dumazet <edumazet@google.com>
> CC: Tim Hockin <thockin@google.com>
> CC: Alex Pollitt <alex.pollitt@metaswitch.com>
> CC: Matthew Dupre <matthew.dupre@metaswitch.com>
> ---
>   include/net/xfrm.h     | 2 +-
>   net/xfrm/xfrm_policy.c | 4 ++--
>   2 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index d6f6e5006ee9..30f9a351c3b9 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -1067,7 +1067,7 @@ static inline int __xfrm_policy_check2(struct s=
ock *sk, int dir,
>   				       struct sk_buff *skb,
>   				       unsigned int family, int reverse)
>   {
> -	struct net *net =3D dev_net(skb->dev);
> +	struct net *net =3D dev_net(netif_get_l3_dev(skb->dev));
>   	int ndir =3D dir | (reverse ? XFRM_POLICY_MASK + 1 : 0);
>
>   	if (sk && sk->sk_policy[XFRM_POLICY_IN])
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index b5e665b3cfb0..c5942744f2e3 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -2462,7 +2462,7 @@ static inline int secpath_has_nontransport(cons=
t struct sec_path *sp, int k, int
>   int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *s=
kb,
>   			unsigned short family)
>   {
> -	struct net *net =3D dev_net(skb->dev);
> +	struct net *net =3D dev_net(netif_get_l3_dev(skb->dev));
>   	struct xfrm_policy *pol;
>   	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
>   	int npols =3D 0;
> @@ -2620,7 +2620,7 @@ EXPORT_SYMBOL(__xfrm_policy_check);
>
>   int __xfrm_route_forward(struct sk_buff *skb, unsigned short family=
)
>   {
> -	struct net *net =3D dev_net(skb->dev);
> +	struct net *net =3D dev_net(netif_get_l3_dev(skb->dev));
>   	struct flowi fl;
>   	struct dst_entry *dst;
>   	int res =3D 1;
>
