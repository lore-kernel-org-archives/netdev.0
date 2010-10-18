From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/3] net: fail alloc_netdev_mq if queue count < 1
Date: Mon, 18 Oct 2010 22:33:41 +0100
Message-ID: <1287437621.2252.766.camel@achroite.uk.solarflarecom.com>
References: <alpine.DEB.1.00.1010181055300.16090@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:56588 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754609Ab0JRVdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 17:33:45 -0400
In-Reply-To: <alpine.DEB.1.00.1010181055300.16090@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-10-18 at 11:02 -0700, Tom Herbert wrote:
> In alloc_netdev_mq fail if requested queue_count < 1.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/core/dev.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 04972a4..76db105 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5511,6 +5511,12 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
>  
>  	BUG_ON(strlen(name) >= sizeof(dev->name));
>  
> +	if (queue_count < 0) {
> +		printk(KERN_ERR "alloc_netdev: Unable to allocate device "
> +		       "with zero queues.\n");

Off by one?

Ben.

> +		return NULL;
> +	}
> +
>  	alloc_size = sizeof(struct net_device);
>  	if (sizeof_priv) {
>  		/* ensure 32-byte alignment of private area */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

