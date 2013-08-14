From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCHv2 net-next] 6lowpan: handle only real link-local addresses
Date: Wed, 14 Aug 2013 13:08:21 +0200
Message-ID: <20130814110821.GH16264@order.stressinduktion.org>
References: <1376478067-3371-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50962 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526Ab3HNLIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 07:08:23 -0400
Content-Disposition: inline
In-Reply-To: <1376478067-3371-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 14, 2013 at 01:01:07PM +0200, Alexander Aring wrote:
> diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
> index 4b8f917..61f0ce9 100644
> --- a/net/ieee802154/6lowpan.h
> +++ b/net/ieee802154/6lowpan.h
> @@ -83,8 +83,11 @@
>  #define ipaddr_prefixcmp(addr1, addr2, length) \
>  	(memcmp(addr1, addr2, length >> 3) == 0)
>  
> -/* local link, i.e. FE80::/10 */
> -#define is_addr_link_local(a) (((a)->s6_addr16[0]) == htons(0xFE80))
> +/* link-local, i.e. FE80::/64 */
> +#define is_addr_link_local(a) (((a)->s6_addr16[0]) == htons(0xFE80) &&	\
> +		(((a)->s6_addr16[1]) == 0) &&	\
> +		(((a)->s6_addr16[2]) == 0) &&	\
> +		(((a)->s6_addr16[3]) == 0))
>  

Can't you use ipv6_addr_type(a)&IPV6_ADDR_LINKLOCAL?

Greetings,

  Hannes
