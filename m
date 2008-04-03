From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ibm_newemac: Add support for 460EX/GT-type MAL
	rx-channel handling
Date: Thu, 03 Apr 2008 23:29:00 +1100
Message-ID: <1207225740.10388.321.camel@pasglop>
References: <1207223110-27281-1-git-send-email-sr@denx.de>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:60488 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061AbYDCM3j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Apr 2008 08:29:39 -0400
In-Reply-To: <1207223110-27281-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-04-03 at 13:45 +0200, Stefan Roese wrote:
> On some 4xx PPC's (e.g. 460EX/GT), the rx channel number is a multiple
> of 8 (e.g. 8 for EMAC1, 16 for EMAC2), but enabling in MAL_RXCASR needs
> the divided by 8 value for the bitmask.

Sounds ok, but I wonder if we ever have a MAL with more than 8 chans, do
we need to make this shift conditional to some device tree prop ?

> Signed-off-by: Stefan Roese <sr@denx.de>
> ---
>  drivers/net/ibm_newemac/mal.c |   16 ++++++++++++++++
>  1 files changed, 16 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ibm_newemac/mal.c
> index 6869f08..fb9c9eb 100644
> --- a/drivers/net/ibm_newemac/mal.c
> +++ b/drivers/net/ibm_newemac/mal.c
> @@ -136,6 +136,14 @@ void mal_enable_rx_channel(struct mal_instance *mal, int channel)
>  {
>  	unsigned long flags;
>  
> +	/*
> +	 * On some 4xx PPC's (e.g. 460EX/GT), the rx channel is a multiple
> +	 * of 8, but enabling in MAL_RXCASR needs the divided by 8 value
> +	 * for the bitmask
> +	 */
> +	if (!(channel % 8))
> +		channel >>= 3;
> +
>  	spin_lock_irqsave(&mal->lock, flags);
>  
>  	MAL_DBG(mal, "enable_rx(%d)" NL, channel);
> @@ -148,6 +156,14 @@ void mal_enable_rx_channel(struct mal_instance *mal, int channel)
>  
>  void mal_disable_rx_channel(struct mal_instance *mal, int channel)
>  {
> +	/*
> +	 * On some 4xx PPC's (e.g. 460EX/GT), the rx channel is a multiple
> +	 * of 8, but enabling in MAL_RXCASR needs the divided by 8 value
> +	 * for the bitmask
> +	 */
> +	if (!(channel % 8))
> +		channel >>= 3;
> +
>  	set_mal_dcrn(mal, MAL_RXCARR, MAL_CHAN_MASK(channel));
>  
>  	MAL_DBG(mal, "disable_rx(%d)" NL, channel);

