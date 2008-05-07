From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: New driver "sfc" for Solarstorm SFC4000 controller.
Date: Wed, 7 May 2008 18:55:19 +0100
Message-ID: <20080507175518.GY2217@solarflare.com>
References: <200804301925.m3UJPc72001651@hera.kernel.org> <20080501120858.207b6dd6.akpm@linux-foundation.org> <20080502160530.GN14219@solarflare.com> <20080502110908.93c79d81.akpm@linux-foundation.org> <20080506125008.GA2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:56598 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751656AbYEGRzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 13:55:33 -0400
Content-Disposition: inline
In-Reply-To: <20080506125008.GA2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Andrew Morton wrote:
> > On Fri, 2 May 2008 17:05:35 +0100 Ben Hutchings <bhutchings@solarflare.com> wrote:
<snip>
> > > > > +		rx_buf->page = alloc_pages(__GFP_COLD | __GFP_COMP | GFP_ATOMIC,
> > > > > +					   efx->rx_buffer_order);
> > > > 
> > > > I don't think we should be using the open-coded __GFP_COMP here.  That's
> > > > more an mm-internal thing.
> > > 
> > > What's the alternative?
> > 
> > Just remove the __GFP_COMP, I expect.  __GFP_COMP will ask the page
> > allocator to add extra book-keeping info to the pageframe (via
> > prep_compound_page()).  I doubt if the driver uses that information.
> 
> It looks like this flag was used by mistake, based on past experience with
> a driver that needed buffers to be mapped into user space.  The original
> author of the RX page-allocation code is away at the moment, so I will
> have to wait to ask why he used it.

This is not a mistake.   We need multi-page buffers to be treated as
compound pages because once they are attached to an skbuff they will
be freed by skb_release_data() calling put_page(), not __free_pages().

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
