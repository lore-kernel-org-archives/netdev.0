From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: New driver "sfc" for Solarstorm SFC4000 controller.
Date: Tue, 6 May 2008 16:40:43 +0100
Message-ID: <20080506154042.GD2217@solarflare.com>
References: <200804301925.m3UJPc72001651@hera.kernel.org> <20080501120858.207b6dd6.akpm@linux-foundation.org> <20080502160530.GN14219@solarflare.com> <20080502110908.93c79d81.akpm@linux-foundation.org> <20080506125008.GA2217@solarflare.com> <20080506072442.82a834c8.akpm@linux-foundation.org> <20080506150450.GB2217@solarflare.com> <20080506081225.637df034.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53553 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757479AbYEFPlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 11:41:00 -0400
Content-Disposition: inline
In-Reply-To: <20080506081225.637df034.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Tue, 6 May 2008 16:04:53 +0100 Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> > > or
> > > 
> > >  	while (*dma_done != FALCON_STATS_DONE) {
> > > 		udelay(1);
> > > 		if (++timeout > TIMEOUT)
> > > 			goto timeout;
> > > 	}
> >  
> > On some architectures udelay() is defined using inline assembly that is not
> > specified as clobbering memory.  So the compiler need not reload *dma_done
> > after calling it, and this doesn't work.
> 
> So pop a cpu_relax() in there as the document describes?

That changes the timing, though it may not matter that much.

Seems to me that this is actually in the last set of "situations where
volatile makes sense":

  - Pointers to data structures in coherent memory which might be modified
    by I/O devices can, sometimes, legitimately be volatile.  A ring buffer
    used by a network adapter, where that adapter changes pointers to
    indicate which descriptors have been processed, is an example of this
    type of situation.

So we could add declare dma_done as volatile u32 * and not do anything
clever in the loop.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
