From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 4/8] ethoc: prevent overflow of rx counter
Date: Wed, 24 Nov 2010 16:30:13 +0000
Message-ID: <1290616213.3013.600.camel@localhost>
References: <1290606058-26703-1-git-send-email-jonas@southpole.se>
	 <1290606058-26703-5-git-send-email-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:56141 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755026Ab0KXQaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 11:30:16 -0500
In-Reply-To: <1290606058-26703-5-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-11-24 at 14:40 +0100, Jonas Bonn wrote:
> Rewind cur_rx to prevent it from overflowing.
> 
> Signed-off-by: Jonas Bonn <jonas@southpole.se>
> ---
>  drivers/net/ethoc.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
> index 53c03f2..7d1b5d8 100644
> --- a/drivers/net/ethoc.c
> +++ b/drivers/net/ethoc.c
> @@ -408,6 +408,9 @@ static int ethoc_rx(struct net_device *dev, int limit)
>  	struct ethoc *priv = netdev_priv(dev);
>  	int count;
>  
> +	/* Prevent overflow of priv->cur_rx by rewinding it */	
> +	priv->cur_rx = priv->cur_rx % priv->num_rx;
> +

Division is expensive; you should either use masking (if priv->num_rx is
guaranteed to be a power of 2) or check for overflow whenever you
increment priv->cur_rx:

	if (++priv->cur_rx == priv->num_rx)
		priv->cur_rx = 0;

Ben.

>  	for (count = 0; count < limit; ++count) {
>  		unsigned int entry;
>  		struct ethoc_bd bd;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

