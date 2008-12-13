From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 25/33] sfc: Generate unique names for per-NIC workqueues
Date: Fri, 12 Dec 2008 22:04:31 -0800 (PST)
Message-ID: <20081212.220431.165056851.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212125656.GY10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57106
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750745AbYLMGE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 01:04:29 -0500
In-Reply-To: <20081212125656.GY10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:56:57 +0000

> @@ -1854,6 +1854,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
>  	struct efx_channel *channel;
>  	struct efx_tx_queue *tx_queue;
>  	struct efx_rx_queue *rx_queue;
> +	char name[16];
...
> @@ -1924,7 +1925,9 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
>  	efx->interrupt_mode = max(efx->type->max_interrupt_mode,
>  				  interrupt_mode);
>  
> -	efx->workqueue = create_singlethread_workqueue("sfc_work");
> +	/* Would be good to use the net_dev name, but we're too early */
> +	snprintf(name, sizeof(name), "sfc%s", pci_name(pci_dev));
> +	efx->workqueue = create_singlethread_workqueue(name);
>  	if (!efx->workqueue)

This change is buggy.

create_singlethread_workqueue() is going to reference this
name buffer on the stack for the life of the workqueue, but
once this function returns that reference will no longer
be valid.

You'll need to use kmalloc()'d memory and free it later,
or something like that.

Patch not applied.
