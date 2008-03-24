From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] New driver "sfc" for Solarstorm SFC4000 controller
 (try #8)
Date: Mon, 24 Mar 2008 13:22:53 -0700 (PDT)
Message-ID: <20080324.132253.110641003.davem@davemloft.net>
References: <20080312012246.GC24160@solarflare.com>
	<20080323.223238.86781188.davem@davemloft.net>
	<20080324102936.GZ24160@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	jgarzik@pobox.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52920
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753191AbYCXUWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 16:22:54 -0400
In-Reply-To: <20080324102936.GZ24160@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 24 Mar 2008 10:29:38 +0000

> David Miller wrote:
> > > +
> > > +		if (rss_cpus == 0) {
> > > +#ifdef topology_core_siblings
> > > +			cpumask_t core_mask;
> > > +			int cpu;
> > > +
> > > +			cpus_clear(core_mask);
> > > +			efx->rss_queues = 0;
> > > +			for_each_online_cpu(cpu) {
> > > +				if (!cpu_isset(cpu, core_mask)) {
> > > +					++efx->rss_queues;
> > > +					cpus_or(core_mask, core_mask,
> > > +						topology_core_siblings(cpu));
> > > +				}
> > > +			}
> > > +#else
> > > +			efx->rss_queues = num_online_cpus();
> > > +#endif
> > 
> > Please don't test feature availability this way.
> > 
> > Either use the proper CONFIG_* option ifdef.
> 
> The macro is defined for some architectures and not for others, and does
> not depend on config options.  See Documentation/cputopology.txt.

Then this needs to be fixed at the top level because drivers doing
this is beyond ugly.

I'd suggest that some default define be provided by the generic
header files so code doesn't have to do this.
