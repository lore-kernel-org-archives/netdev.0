From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCHv3 net-next 05/12] ndisc: add __ndisc_opt_addr_data
 function
Date: Wed, 15 Jun 2016 17:11:48 +0200
Message-ID: <57617034.5050803@osg.samsung.com>
References: <20160614115239.17788-1-aar@pengutronix.de>
 <20160614115239.17788-6-aar@pengutronix.de>
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
Received: from lists.s-osg.org ([54.187.51.154]:60587 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753390AbcFOPL7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 11:11:59 -0400
In-Reply-To: <20160614115239.17788-6-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 14/06/16 13:52, Alexander Aring wrote:
> This patch adds __ndisc_opt_addr_data as low-level function for
> ndisc_opt_addr_data which doesn't depend on net_device parameter.
>
> Cc: David S. Miller<davem@davemloft.net>
> Cc: Alexey Kuznetsov<kuznet@ms2.inr.ac.ru>
> Cc: James Morris<jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI<yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy<kaber@trash.net>
> Signed-off-by: Alexander Aring<aar@pengutronix.de>
> ---
>   include/net/ndisc.h | 14 ++++++++++----
>   1 file changed, 10 insertions(+), 4 deletions(-)
>
> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
> index 4cee826..c8962ad 100644
> --- a/include/net/ndisc.h
> +++ b/include/net/ndisc.h
> @@ -138,17 +138,23 @@ static inline int ndisc_opt_addr_space(struct net_device *dev)
>   				      ndisc_addr_option_pad(dev->type));
>   }
>   
> -static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
> -				      struct net_device *dev)
> +static inline u8 *__ndisc_opt_addr_data(struct nd_opt_hdr *p,
> +					unsigned char addr_len, int prepad)
>   {
>   	u8 *lladdr = (u8 *)(p + 1);
>   	int lladdrlen = p->nd_opt_len << 3;
> -	int prepad = ndisc_addr_option_pad(dev->type);
> -	if (lladdrlen != ndisc_opt_addr_space(dev))
> +	if (lladdrlen != __ndisc_opt_addr_space(addr_len, prepad))
>   		return NULL;
>   	return lladdr + prepad;
>   }
>   
> +static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
> +				      struct net_device *dev)
> +{
> +	return __ndisc_opt_addr_data(p, dev->addr_len,
> +				     ndisc_addr_option_pad(dev->type));
> +}
> +
>   static inline u32 ndisc_hashfn(const void *pkey, const struct net_device *dev, __u32 *hash_rnd)
>   {
>   	const u32 *p32 = pkey;

Reviewed-by: Stefan Schmidt<stefan@osg.samsung.com>

regards
Stefan Schmidt
