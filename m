From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCHv3 net-next 06/12] ndisc: add __ndisc_fill_addr_option
 function
Date: Wed, 15 Jun 2016 17:13:10 +0200
Message-ID: <57617086.8090208@osg.samsung.com>
References: <20160614115239.17788-1-aar@pengutronix.de>
 <20160614115239.17788-7-aar@pengutronix.de>
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
Received: from lists.s-osg.org ([54.187.51.154]:60614 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932946AbcFOPNQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 11:13:16 -0400
In-Reply-To: <20160614115239.17788-7-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 14/06/16 13:52, Alexander Aring wrote:
> This patch adds __ndisc_fill_addr_option as low-level function for
> ndisc_fill_addr_option which doesn't depend on net_device parameter.
>
> Cc: David S. Miller<davem@davemloft.net>
> Cc: Alexey Kuznetsov<kuznet@ms2.inr.ac.ru>
> Cc: James Morris<jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI<yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy<kaber@trash.net>
> Signed-off-by: Alexander Aring<aar@pengutronix.de>
> ---
>   net/ipv6/ndisc.c | 14 ++++++++++----
>   1 file changed, 10 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index c245895..a7b9468 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -150,11 +150,10 @@ struct neigh_table nd_tbl = {
>   };
>   EXPORT_SYMBOL_GPL(nd_tbl);
>   
> -static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data)
> +static void __ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
> +				     int data_len, int pad)
>   {
> -	int pad   = ndisc_addr_option_pad(skb->dev->type);
> -	int data_len = skb->dev->addr_len;
> -	int space = ndisc_opt_addr_space(skb->dev);
> +	int space = __ndisc_opt_addr_space(data_len, pad);
>   	u8 *opt = skb_put(skb, space);
>   
>   	opt[0] = type;
> @@ -172,6 +171,13 @@ static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data)
>   		memset(opt, 0, space);
>   }
>   
> +static inline void ndisc_fill_addr_option(struct sk_buff *skb, int type,
> +					  void *data)
> +{
> +	__ndisc_fill_addr_option(skb, type, data, skb->dev->addr_len,
> +				 ndisc_addr_option_pad(skb->dev->type));
> +}
> +
>   static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
>   					    struct nd_opt_hdr *end)
>   {

Reviewed-by: Stefan Schmidt<stefan@osg.samsung.com>

regards
Stefan Schmidt
