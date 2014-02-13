From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] IPv6: enable bind() to assign an anycast address
Date: Thu, 13 Feb 2014 01:16:24 +0100
Message-ID: <20140213001624.GJ11150@order.stressinduktion.org>
References: <1392212332-10463-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: NETDEV <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	christoph.paasch@uclouvain.be, eric.dumazet@gmail.com
To: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50761 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbaBMAQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 19:16:25 -0500
Content-Disposition: inline
In-Reply-To: <1392212332-10463-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

[added Cc list from old thread]

On Wed, Feb 12, 2014 at 02:38:51PM +0100, Francois-Xavier Le Bail wrote:
> - Use ipv6_chk_acast_addr_src() in inet6_bind().
> 
> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>

I would agree with the change but would like to see some people from the old
thread about this change to agree with it, too.

> ---
> v2: ipv6_chk_acast_addr_src() was previously added.
> 
>  net/ipv6/af_inet6.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index c921d5d..68b81e9 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -347,7 +347,9 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
>  			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
>  				if (!(inet->freebind || inet->transparent) &&
>  				    !ipv6_chk_addr(net, &addr->sin6_addr,
> -						   dev, 0)) {
> +						   dev, 0) &&
> +				    !ipv6_chk_acast_addr_src(net, dev,
> +							     &addr->sin6_addr)) {
>  					err = -EADDRNOTAVAIL;
>  					goto out_unlock;
>  				}

Thanks,

  Hannes
