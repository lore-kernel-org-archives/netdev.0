From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] ksz884x: fix Endian
Date: Fri, 6 Jul 2012 23:40:16 +0100
Message-ID: <1341614416.2923.12.camel@bwh-desktop.uk.solarflarecom.com>
References: <1341454003-11227-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <Tristram.Ha@micrel.com>
To: <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30660 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756548Ab2GFWkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 18:40:18 -0400
In-Reply-To: <1341454003-11227-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-05 at 10:06 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> ETH_P_IP is host Endian, skb->protocol is big Endian, when
> compare them, we should change skb->protocol from big endian
> to host endian, ntohs, not htons.
> 
> CC: Tristram Ha <Tristram.Ha@micrel.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  drivers/net/ethernet/micrel/ksz884x.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
> index eaf9ff0..d9727f7 100644
> --- a/drivers/net/ethernet/micrel/ksz884x.c
> +++ b/drivers/net/ethernet/micrel/ksz884x.c
> @@ -4882,7 +4882,7 @@ static netdev_tx_t netdev_tx(struct sk_buff *skb, struct net_device *dev)
>  	if (left) {
>  		if (left < num ||
>  				((CHECKSUM_PARTIAL == skb->ip_summed) &&
> -				(ETH_P_IPV6 == htons(skb->protocol)))) {
> +				(ETH_P_IPV6 == ntohs(skb->protocol)))) {

This should really be changed to the idiomatic 'skb->protocol ==
htons(ETH_P_IPV6)'.  For the current code, the compiler will probably
generate a run-time byte-swap for little-endian systems.

Ben.

>  			struct sk_buff *org_skb = skb;
>  
>  			skb = netdev_alloc_skb(dev, org_skb->len);

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
