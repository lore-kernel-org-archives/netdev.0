From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/8] New driver "sfc" for Solarstorm SFC4000 controller (try #8)
Date: Tue, 25 Mar 2008 12:54:23 +0000
Message-ID: <20080325125421.GB24160@solarflare.com>
References: <20080312012246.GC24160@solarflare.com> <20080323.223238.86781188.davem@davemloft.net> <20080324102936.GZ24160@solarflare.com> <20080324.132253.110641003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:56447 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753262AbYCYMyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 08:54:52 -0400
Content-Disposition: inline
In-Reply-To: <20080324.132253.110641003.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 24 Mar 2008 10:29:38 +0000
> 
> > David Miller wrote:
> > > > +
> > > > +		if (rss_cpus == 0) {
> > > > +#ifdef topology_core_siblings
> > > > +			cpumask_t core_mask;
> > > > +			int cpu;
> > > > +
> > > > +			cpus_clear(core_mask);
> > > > +			efx->rss_queues = 0;
> > > > +			for_each_online_cpu(cpu) {
> > > > +				if (!cpu_isset(cpu, core_mask)) {
> > > > +					++efx->rss_queues;
> > > > +					cpus_or(core_mask, core_mask,
> > > > +						topology_core_siblings(cpu));
> > > > +				}
> > > > +			}
> > > > +#else
> > > > +			efx->rss_queues = num_online_cpus();
> > > > +#endif
> > > 
> > > Please don't test feature availability this way.
> > > 
> > > Either use the proper CONFIG_* option ifdef.
> > 
> > The macro is defined for some architectures and not for others, and does
> > not depend on config options.  See Documentation/cputopology.txt.
> 
> Then this needs to be fixed at the top level because drivers doing
> this is beyond ugly.
> 
> I'd suggest that some default define be provided by the generic
> header files so code doesn't have to do this.

That would certainly be better, yes.

Would you object to our using this test until the default definition exists?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
