From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCHv3 net-next 04/12] ndisc: add __ndisc_opt_addr_space
 function
Date: Wed, 15 Jun 2016 20:07:01 +0900
Message-ID: <576136D5.4050706@miraclelinux.com>
References: <20160614115239.17788-1-aar@pengutronix.de>
 <20160614115239.17788-5-aar@pengutronix.de>
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
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34224 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896AbcFOLHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 07:07:07 -0400
Received: by mail-pa0-f49.google.com with SMTP id bz2so6664456pad.1
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 04:07:07 -0700 (PDT)
In-Reply-To: <20160614115239.17788-5-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Aring wrote:
> This patch adds __ndisc_opt_addr_space as low-level function for
> ndisc_opt_addr_space which doesn't depend on net_device parameter.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Alexander Aring <aar@pengutronix.de>

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

> ---
>  include/net/ndisc.h | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
> index 2d8edaa..4cee826 100644
> --- a/include/net/ndisc.h
> +++ b/include/net/ndisc.h
> @@ -127,10 +127,15 @@ static inline int ndisc_addr_option_pad(unsigned short type)
>  	}
>  }
>  
> +static inline int __ndisc_opt_addr_space(unsigned char addr_len, int pad)
> +{
> +	return NDISC_OPT_SPACE(addr_len + pad);
> +}
> +
>  static inline int ndisc_opt_addr_space(struct net_device *dev)
>  {
> -	return NDISC_OPT_SPACE(dev->addr_len +
> -			       ndisc_addr_option_pad(dev->type));
> +	return __ndisc_opt_addr_space(dev->addr_len,
> +				      ndisc_addr_option_pad(dev->type));
>  }
>  
>  static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
> 

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
