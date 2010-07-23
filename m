From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] macvlan: Fix rx counters update in
	macvlan_handle_frame()
Date: Fri, 23 Jul 2010 15:23:39 +0800
Message-ID: <20100723072338.GA4267@gondor.apana.org.au>
References: <1279839867.3274.25.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:34304 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620Ab0GWHXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 03:23:46 -0400
Content-Disposition: inline
In-Reply-To: <1279839867.3274.25.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 22, 2010 at 04:04:27PM -0700, Sridhar Samudrala wrote:
> Fix macvlan_handle_frame() to update the rx counters based
> on the return value of the vlan->receive call.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 87e8d4c..2732df1 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -152,7 +152,8 @@ static struct sk_buff *macvlan_handle_frame(struct macvlan_port *port,
>  	const struct macvlan_dev *vlan;
>  	const struct macvlan_dev *src;
>  	struct net_device *dev;
> -	unsigned int len;
> +	unsigned int len = 0;
> +	int ret = NET_RX_DROP;
>  
>  	if (is_multicast_ether_addr(eth->h_dest)) {
>  		src = macvlan_hash_lookup(port, eth->h_source);
> @@ -184,18 +185,20 @@ static struct sk_buff *macvlan_handle_frame(struct macvlan_port *port,
>  	dev = vlan->dev;
>  	if (unlikely(!(dev->flags & IFF_UP))) {
>  		kfree_skb(skb);
> -		return NULL;
> +		goto out;

I don't think we should count packet drops when the interface is
down.  This would be inconsistent with other devices such as
IPIP.

Otherthis your patch looks good to me.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
