From: Ralph Campbell <ralphc@pathscale.com>
Subject: Re: [openib-general] [PATCH 39 of 39] IB/ipath - use streaming
	copy in RDMA interrupt handler to reduce packet loss
Date: Thu, 29 Jun 2006 16:55:41 -0700
Message-ID: <1151625341.4572.133.camel@brick.pathscale.com>
References: <1151618377.10886.23.camel@chalcedony.pathscale.com>
	 <20060629.150319.104035601.davem@davemloft.net>
	 <1151624063.10886.34.camel@chalcedony.pathscale.com>
	 <20060629.164623.59469884.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bos@pathscale.com, akpm@osdl.org, netdev@vger.kernel.org,
	rdreier@cisco.com, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.pathscale.com ([64.160.42.68]:45979 "EHLO mx.pathscale.com")
	by vger.kernel.org with ESMTP id S1751318AbWF2Xzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 19:55:43 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060629.164623.59469884.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is intended to be an architecture specific function
so if the CPU does support HW dma to the CPU's L2 cache, the
architecture specific version of memcpy_nc() would not replace
the default definition which maps memcpy_nc() to memcpy().

For CPUs like the vast majority currently available, there
is a performance benefit by not reading data into the cache
that won't be read a second time.

On Thu, 2006-06-29 at 16:46 -0700, David Miller wrote:
> From: Bryan O'Sullivan <bos@pathscale.com>
> Date: Thu, 29 Jun 2006 16:34:23 -0700
> 
> > I'm not quite following you, though I assume you're referring to Niagara
> > or Rock :-)  Are you saying a memcpy_nc would do worse than plain
> > memcpy, or worse than some other memcpy-like routine?
> 
> It would do worse than memcpy.
> 
> If you bypass the L2 cache, it's pointless because the next
> agent (PCI controller, CPU thread, etc.) is going to need the
> data in the L2 cache.
> 
> It's better in that kind of setup to eat the L2 cache miss overhead in
> memcpy since memcpy can usually prefetch and store buffer in order to
> absorb some of the L2 miss costs.
> 
> _______________________________________________
> openib-general mailing list
> openib-general@openib.org
> http://openib.org/mailman/listinfo/openib-general
> 
> To unsubscribe, please visit http://openib.org/mailman/listinfo/openib-general
> 

