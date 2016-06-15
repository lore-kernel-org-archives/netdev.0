From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCHv3 net-next 06/12] ndisc: add __ndisc_fill_addr_option
 function
Date: Wed, 15 Jun 2016 20:08:35 +0900
Message-ID: <57613733.4090007@miraclelinux.com>
References: <20160614115239.17788-1-aar@pengutronix.de>
 <20160614115239.17788-7-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, kernel@pengutronix.de,
	marcel@holtmann.org, jukka.rissanen@linux.intel.com,
	hannes@stressinduktion.org, stefan@osg.samsung.com,
	mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexander Aring <aar@pengutronix.de>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35839 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbcFOLIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 07:08:41 -0400
Received: by mail-pf0-f179.google.com with SMTP id c2so7990018pfa.2
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 04:08:41 -0700 (PDT)
In-Reply-To: <20160614115239.17788-7-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Alexander Aring wrote:
> This patch adds __ndisc_fill_addr_option as low-level function for
> ndisc_fill_addr_option which doesn't depend on net_device parameter.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Alexander Aring <aar@pengutronix.de>


Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

> ---
>  net/ipv6/ndisc.c | 14 ++++++++++----
>  1 file changed, 10 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index c245895..a7b9468 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -150,11 +150,10 @@ struct neigh_table nd_tbl = {
>  };
>  EXPORT_SYMBOL_GPL(nd_tbl);
>  
> -static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data)
> +static void __ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
> +				     int data_len, int pad)
>  {
> -	int pad   = ndisc_addr_option_pad(skb->dev->type);
> -	int data_len = skb->dev->addr_len;
> -	int space = ndisc_opt_addr_space(skb->dev);
> +	int space = __ndisc_opt_addr_space(data_len, pad);
>  	u8 *opt = skb_put(skb, space);
>  
>  	opt[0] = type;
> @@ -172,6 +171,13 @@ static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data)
>  		memset(opt, 0, space);
>  }
>  
> +static inline void ndisc_fill_addr_option(struct sk_buff *skb, int type,
> +					  void *data)
> +{
> +	__ndisc_fill_addr_option(skb, type, data, skb->dev->addr_len,
> +				 ndisc_addr_option_pad(skb->dev->type));
> +}
> +
>  static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
>  					    struct nd_opt_hdr *end)
>  {
> 

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
