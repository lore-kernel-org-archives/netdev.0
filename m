From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH net-next 01/11] sfc: Implement 128-bit writes for
 efx_writeo_page
Date: Thu, 12 Jul 2012 17:10:40 +0100
Message-ID: <1342109440.2662.9.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342048389.2613.59.camel@bwh-desktop.uk.solarflarecom.com>
	 <1342048518.2613.60.camel@bwh-desktop.uk.solarflarecom.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B6F7D@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41556 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1161220Ab2GLQKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 12:10:47 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F7D@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-12 at 09:45 +0100, David Laight wrote:
> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > owner@vger.kernel.org] On Behalf Of Ben Hutchings
> > Sent: 12 July 2012 00:15
> > To: David Miller
> > Cc: netdev@vger.kernel.org; linux-net-drivers@solarflare.com
> > Subject: [PATCH net-next 01/11] sfc: Implement 128-bit writes for
> > efx_writeo_page
> > 
> > Add support for writing a TX descriptor to the NIC in one PCIe
> > transaction on x86_64 machines.
> ...
> > +static inline void _efx_writeo(struct efx_nic *efx, efx_le_128 value,
> > +			       unsigned int reg)
> > +{
> ...
> > +}
> 
> Wouldn't it be better to put code this in some generic header
> where it can be used by other drivers?

I can do that, but I'm not sure that it's all that generic.

> Some architectures/cpus have dma engines associated with the
> PCIe interface than can be used to request longer PCIe transactions.
>
> So you probably need a transfer length as well.
> 
> I suspect that it is never worth using an interrupt for
> the completion of such dma - although splitting the request
> and wait would allow the caller to overlap operations.
> 
> With a dma interface it is worth updating multiple ring
> entries at one, and reading multiple entries for status.

We're trying to reduce latency.  You seem to be talking about batching
to increase efficiency at the cost of latency.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
