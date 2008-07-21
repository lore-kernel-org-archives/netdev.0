From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Make simple TX hash little endian safe.
Date: Mon, 21 Jul 2008 12:32:15 +0000
Message-ID: <20080721123215.GA4376@ff.dom.local>
References: <1216630088-10328-1-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:36530 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698AbYGUM1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 08:27:12 -0400
Received: by fg-out-1718.google.com with SMTP id 19so635447fgg.17
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 05:27:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1216630088-10328-1-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21-07-2008 10:48, Andi Kleen wrote:
> From: Andi Kleen <andi@basil.nowhere.org>
> 
> Currently it will not use the lower
> bits at all on big endian system, mapping e.g. all connections to a single
> queue on a local network which only differs in the low bits.

It seems ports could be treated similarly, btw?

Jarek P.

> 
> Also fold the upper 16 bits always in the lower 16bits.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
>  net/core/dev.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 2eed17b..c35fefc 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1694,8 +1694,11 @@ static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *skb)
>  	ports = (u32 *) (skb_network_header(skb) + (ihl * 4));
>  
>  	hash = 0;
> -	while (alen--)
> -		hash ^= *addr++;
> +	while (alen--) {
> +		hash ^= ntohl(*addr); 
> +		addr++;
> +	}
> +	hash ^= hash >> 16; /* More folding needed? */
>  
>  	switch (ip_proto) {
>  	case IPPROTO_TCP:
