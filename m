From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCHv2 bluetooth-next 06/10] ndisc: add addr_len parameter to
 ndisc_fill_addr_option
Date: Tue, 3 May 2016 20:17:24 +0200
Message-ID: <5728EB34.6040506@osg.samsung.com>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de>
 <1461140382-4784-7-git-send-email-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, hannes@stressinduktion.org,
	mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexander Aring <aar@pengutronix.de>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:57948 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933754AbcECSRa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 14:17:30 -0400
In-Reply-To: <1461140382-4784-7-git-send-email-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 20/04/16 10:19, Alexander Aring wrote:
> This patch makes the address length as argument for the
> ndisc_fill_addr_option function. This is necessary to handle addresses
> which don't use dev->addr_len as address length.
>
> Cc: David S. Miller<davem@davemloft.net>
> Cc: Alexey Kuznetsov<kuznet@ms2.inr.ac.ru>
> Cc: James Morris<jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI<yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy<kaber@trash.net>
> Signed-off-by: Alexander Aring<aar@pengutronix.de>
> ---
>   net/ipv6/ndisc.c | 15 ++++++++-------
>   1 file changed, 8 insertions(+), 7 deletions(-)
>
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 4e91d5e..176c7c4 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -150,11 +150,11 @@ struct neigh_table nd_tbl = {
>   };
>   EXPORT_SYMBOL_GPL(nd_tbl);
>   
> -static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data)
> +static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
> +				   int data_len)
>   {
>   	int pad   = ndisc_addr_option_pad(skb->dev->type);
> -	int data_len = skb->dev->addr_len;
> -	int space = ndisc_opt_addr_space(skb->dev, skb->dev->addr_len);
> +	int space = ndisc_opt_addr_space(skb->dev, data_len);
>   	u8 *opt = skb_put(skb, space);
>   
>   	opt[0] = type;
> @@ -528,7 +528,7 @@ void ndisc_send_na(struct net_device *dev, const struct in6_addr *daddr,
>   
>   	if (inc_opt)
>   		ndisc_fill_addr_option(skb, ND_OPT_TARGET_LL_ADDR,
> -				       dev->dev_addr);
> +				       dev->dev_addr, dev->addr_len);
>   
>   
>   	ndisc_send_skb(skb, daddr, src_addr);
> @@ -590,7 +590,7 @@ void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
>   
>   	if (inc_opt)
>   		ndisc_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR,
> -				       dev->dev_addr);
> +				       dev->dev_addr, dev->addr_len);
>   
>   	ndisc_send_skb(skb, daddr, saddr);
>   }
> @@ -641,7 +641,7 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
>   
>   	if (send_sllao)
>   		ndisc_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR,
> -				       dev->dev_addr);
> +				       dev->dev_addr, dev->addr_len);
>   
>   	ndisc_send_skb(skb, daddr, saddr);
>   }
> @@ -1597,7 +1597,8 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
>   	 */
>   
>   	if (ha)
> -		ndisc_fill_addr_option(buff, ND_OPT_TARGET_LL_ADDR, ha);
> +		ndisc_fill_addr_option(buff, ND_OPT_TARGET_LL_ADDR, ha,
> +				       dev->addr_len);
>   
>   	/*
>   	 *	build redirect option and copy skb over to the new packet.

Reviewed-by: Stefan Schmidt<stefan@osg.samsung.com>

regards
Stefan Schmidt
