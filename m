From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Make hw->ports the number of ports allocated
Date: Fri, 11 Sep 2009 21:43:58 -0700
Message-ID: <20090911214358.7096f544@nehalam>
References: <4AAB133B.8070900@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58509 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750705AbZILEoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Sep 2009 00:44:10 -0400
In-Reply-To: <4AAB133B.8070900@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Sep 2009 12:19:23 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> If allocation of the second ports fails, make sure that hw->ports
>  is not 2 otherwise we'll crash trying to access the second port.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>
> ---
>  drivers/net/sky2.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index 018aa58..c17ee26 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -4563,6 +4563,10 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
>  			free_netdev(dev1);
>  		} else
>  			sky2_show_addr(dev1);
> +
> +		/* couldn't allocate the second port */
> +		if (!hw->dev[1])
> +			--hw->ports;
>  	}
>  
>  	setup_timer(&hw->watchdog_timer, sky2_watchdog, (unsigned long) hw);

If it couldn't allocate the port, would be better to unwind the first port
and fail the probe, rather than silently failing in a really sick system.

-- 
