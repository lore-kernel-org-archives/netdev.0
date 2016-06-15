From: YOSHIFUJI Hideaki <hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org>
Subject: Re: [PATCHv3 net-next 05/12] ndisc: add __ndisc_opt_addr_data
 function
Date: Wed, 15 Jun 2016 20:07:49 +0900
Message-ID: <57613705.1040101@miraclelinux.com>
References: <20160614115239.17788-1-aar@pengutronix.de>
 <20160614115239.17788-6-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org, kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org,
	mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, werner-SEdMjqphH88wryQfseakQg@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160614115239.17788-6-aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



Alexander Aring wrote:
> This patch adds __ndisc_opt_addr_data as low-level function for
> ndisc_opt_addr_data which doesn't depend on net_device parameter.
> 
> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
> Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
> Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
> Signed-off-by: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

Acked-by: YOSHIFUJI Hideaki <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>

> ---
>  include/net/ndisc.h | 14 ++++++++++----
>  1 file changed, 10 insertions(+), 4 deletions(-)
> 
> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
> index 4cee826..c8962ad 100644
> --- a/include/net/ndisc.h
> +++ b/include/net/ndisc.h
> @@ -138,17 +138,23 @@ static inline int ndisc_opt_addr_space(struct net_device *dev)
>  				      ndisc_addr_option_pad(dev->type));
>  }
>  
> -static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
> -				      struct net_device *dev)
> +static inline u8 *__ndisc_opt_addr_data(struct nd_opt_hdr *p,
> +					unsigned char addr_len, int prepad)
>  {
>  	u8 *lladdr = (u8 *)(p + 1);
>  	int lladdrlen = p->nd_opt_len << 3;
> -	int prepad = ndisc_addr_option_pad(dev->type);
> -	if (lladdrlen != ndisc_opt_addr_space(dev))
> +	if (lladdrlen != __ndisc_opt_addr_space(addr_len, prepad))
>  		return NULL;
>  	return lladdr + prepad;
>  }
>  
> +static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
> +				      struct net_device *dev)
> +{
> +	return __ndisc_opt_addr_data(p, dev->addr_len,
> +				     ndisc_addr_option_pad(dev->type));
> +}
> +
>  static inline u32 ndisc_hashfn(const void *pkey, const struct net_device *dev, __u32 *hash_rnd)
>  {
>  	const u32 *p32 = pkey;
> 

-- 
Hideaki Yoshifuji <hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org>
Technical Division, MIRACLE LINUX CORPORATION
