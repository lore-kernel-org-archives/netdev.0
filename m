From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] netpoll: fix race on poll_list resulting in garbage
	entry
Date: Thu, 18 Dec 2008 22:40:15 +0000
Message-ID: <1229640015.2914.20.camel@hashbaz.i.decadent.org.uk>
References: <20081217211628.GD7356@hmsreliant.think-freely.org>
	 <20081217133131.44a4f67f@extreme>
	 <20081218011306.GA32191@hmsreliant.think-freely.org>
	 <20081217.192936.169928910.davem@davemloft.net>
	 <20081218195236.GA5191@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:2509 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752552AbYLRXWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 18:22:09 -0500
In-Reply-To: <20081218195236.GA5191@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-12-18 at 14:52 -0500, Neil Horman wrote:
[...]
> diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
> index 086629c..75273bb 100644
> --- a/drivers/net/sfc/efx.c
> +++ b/drivers/net/sfc/efx.c
> @@ -226,11 +226,11 @@ static int efx_poll(struct napi_struct *napi, int budget)
>  
>  	if (rx_packets < budget) {
>  		/* There is no race here; although napi_disable() will
> -		 * only wait for netif_rx_complete(), this isn't a problem
> +		 * only wait for netif_rx_complete(this isn't a problem
>  		 * since efx_channel_processed() will have no effect if
>  		 * interrupts have already been disabled.
>  		 */
[...]

You'll want to exclude comments from your search-and-replace.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


