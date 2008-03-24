From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 3/3] [LLC]: zero station mac source address
Date: Mon, 24 Mar 2008 14:19:24 -0300
Message-ID: <20080324171924.GA22421@ghostprotocols.net>
References: <47e76799.1cef600a.7b83.6fea@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: joonwpark81@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45239 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753316AbYCXRTh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 13:19:37 -0400
Content-Disposition: inline
In-Reply-To: <47e76799.1cef600a.7b83.6fea@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Mar 24, 2008 at 05:34:30PM +0900, joonwpark81@gmail.com escreveu:
> From: Joonwoo Park <joonwpark81@gmail.com>
> 
> The right next device of the lo can have zero dev_addr. e.g. bonding.
> 
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> ---
>  net/llc/llc_core.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/net/llc/llc_core.c b/net/llc/llc_core.c
> index 248b590..b871e10 100644
> --- a/net/llc/llc_core.c
> +++ b/net/llc/llc_core.c
> @@ -19,6 +19,7 @@
>  #include <linux/slab.h>
>  #include <linux/string.h>
>  #include <linux/init.h>
> +#include <linux/etherdevice.h>
>  #include <net/net_namespace.h>
>  #include <net/llc.h>
>  
> @@ -164,8 +165,9 @@ static int __init llc_init(void)
>  	struct net_device *dev;
>  
>  	dev = first_net_device(&init_net);
> -	if (dev != NULL)
> +	do {
>  		dev = next_net_device(dev);
> +	} while (dev && is_zero_ether_addr(dev->dev_addr));
>  
>  	if (dev != NULL)
>  		memcpy(llc_station_mac_sa, dev->dev_addr, ETH_ALEN);

Looks ok, but I think this is an area for further work, using just
the first device in the list always was wrong, I was too lazy to fix it,
but since you are working on it, please consider fixing this for good
:-)

- Arnaldo
