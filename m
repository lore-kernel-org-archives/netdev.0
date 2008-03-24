From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/8] New driver "sfc" for Solarstorm SFC4000 controller (try #8)
Date: Mon, 24 Mar 2008 10:29:38 +0000
Message-ID: <20080324102936.GZ24160@solarflare.com>
References: <20080312012102.GB24160@solarflare.com> <20080312012246.GC24160@solarflare.com> <20080323.223238.86781188.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53731 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755513AbYCXKaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 06:30:01 -0400
Content-Disposition: inline
In-Reply-To: <20080323.223238.86781188.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Wed, 12 Mar 2008 01:22:48 +0000
> 
> > +static void efx_link_status_changed(struct efx_nic *efx)
> > +{
> > +	unsigned long flags __attribute__ ((unused));
> 
> Please just delete this variable, it really is never
> used not matter what the build configuration.

These are already gone from our internal version, as my colleague Steve
Hodgson also spotted that they are now unused.
> 
> > +
> > +		if (rss_cpus == 0) {
> > +#ifdef topology_core_siblings
> > +			cpumask_t core_mask;
> > +			int cpu;
> > +
> > +			cpus_clear(core_mask);
> > +			efx->rss_queues = 0;
> > +			for_each_online_cpu(cpu) {
> > +				if (!cpu_isset(cpu, core_mask)) {
> > +					++efx->rss_queues;
> > +					cpus_or(core_mask, core_mask,
> > +						topology_core_siblings(cpu));
> > +				}
> > +			}
> > +#else
> > +			efx->rss_queues = num_online_cpus();
> > +#endif
> 
> Please don't test feature availability this way.
> 
> Either use the proper CONFIG_* option ifdef.

The macro is defined for some architectures and not for others, and does
not depend on config options.  See Documentation/cputopology.txt.

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

OK.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
