From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/8] New driver "sfc" for Solarstorm SFC4000 controller (try #8)
Date: Tue, 25 Mar 2008 15:40:10 +0000
Message-ID: <20080325154009.GC24160@solarflare.com>
References: <20080312012102.GB24160@solarflare.com> <20080312012246.GC24160@solarflare.com> <20080323.223238.86781188.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:56799 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755497AbYCYPks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 11:40:48 -0400
Content-Disposition: inline
In-Reply-To: <20080323.223238.86781188.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> > +/* Allocate the NAPI dev's.
> > + * Called after we know how many channels there are.
> > + */
> > +static int efx_init_napi(struct efx_nic *efx)
> > +{
> > +	struct efx_channel *channel;
> > +	int rc;
> > +
> > +	/* Allocate the NAPI dev for the port */
> > +	efx->net_dev = alloc_etherdev(0);
> > +	if (!efx->net_dev) {
> > +		rc = -ENOMEM;
> > +		goto err;
> > +	}
> > +	efx->net_dev->priv = efx;
> > +	efx->mii.dev = efx->net_dev;
> 
> Please use alloc_etherdev() how is was designed, by
> specifying sizeof(struct efx_nic) as the size argument
> and that way your private area gets setup transparently
> and none of these explicit assignments are necessary.

This late allocation of the net-device is a relic of support for
devices with 2 ports on the same PCI function.  I'm fixing it now.
However, I don't see that there's any net saving of assignments.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
