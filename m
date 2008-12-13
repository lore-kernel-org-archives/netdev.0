From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 25/33] sfc: Generate unique names for per-NIC workqueues
Date: Sat, 13 Dec 2008 06:23:03 +0000
Message-ID: <20081213062301.GH10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com> <20081212124622.GK32518@solarflare.com> <20081212125656.GY10372@solarflare.com> <20081212.220431.165056851.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:46729 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750745AbYLMGXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 01:23:08 -0500
Content-Disposition: inline
In-Reply-To: <20081212.220431.165056851.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Fri, 12 Dec 2008 12:56:57 +0000
> 
> > @@ -1854,6 +1854,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
> >  	struct efx_channel *channel;
> >  	struct efx_tx_queue *tx_queue;
> >  	struct efx_rx_queue *rx_queue;
> > +	char name[16];
> ...
> > @@ -1924,7 +1925,9 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
> >  	efx->interrupt_mode = max(efx->type->max_interrupt_mode,
> >  				  interrupt_mode);
> >  
> > -	efx->workqueue = create_singlethread_workqueue("sfc_work");
> > +	/* Would be good to use the net_dev name, but we're too early */
> > +	snprintf(name, sizeof(name), "sfc%s", pci_name(pci_dev));
> > +	efx->workqueue = create_singlethread_workqueue(name);
> >  	if (!efx->workqueue)
> 
> This change is buggy.
> 
> create_singlethread_workqueue() is going to reference this
> name buffer on the stack for the life of the workqueue, but
> once this function returns that reference will no longer
> be valid.
 
No, it's copied into the "comm" field of task_struct.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
