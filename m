From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 3/6] 6lowpan: introduce lowpan_fetch_skb function
Date: Wed, 14 Aug 2013 13:49:21 +0200
Message-ID: <20130814114921.GC2010@order.stressinduktion.org>
References: <1376478108-3539-1-git-send-email-alex.aring@gmail.com> <1376478108-3539-4-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51034 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759692Ab3HNLtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 07:49:22 -0400
Content-Disposition: inline
In-Reply-To: <1376478108-3539-4-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 14, 2013 at 01:01:45PM +0200, Alexander Aring wrote:
> This patch adds a helper function to parse the ipv6 header to a
> 6lowpan header in stream.
> 
> This function checks first if we can pull data with a specific
> length from a skb. If this seems to be okay, we copy skb data to
> a destination pointer and run skb_pull.
> 
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> Reviewed-by: Werner Almesberger <werner@almesberger.net>
> ---
>  net/ieee802154/6lowpan.h | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
> index 61f0ce9..e3348ec 100644
> --- a/net/ieee802154/6lowpan.h
> +++ b/net/ieee802154/6lowpan.h
> @@ -233,4 +233,16 @@
>  					dest = 16 bit inline */
>  #define LOWPAN_NHC_UDP_CS_P_11	0xF3 /* source & dest = 0xF0B + 4bit inline */
>  
> +static inline bool lowpan_fetch_skb(struct sk_buff *skb,
> +		void *data, const unsigned int len)
> +{
> +	if (unlikely(!pskb_may_pull(skb, len)))
> +		return true;
> +
> +	skb_copy_from_linear_data(skb, data, len);
> +	skb_pull(skb, len);
> +
> +	return false;
> +}

Isn't the return value inverted here?

Greetings,

  Hannes
