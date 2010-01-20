From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 02/11] sky2: fix DMA sync_single length error
Date: Thu, 21 Jan 2010 00:52:45 +0100
Message-ID: <20100120235245.GE3072@del.dom.local>
References: <20100120213259.GB3072@del.dom.local>
 <20100120.145218.259766536.davem@davemloft.net>
 <20100120232102.GD3072@del.dom.local>
 <20100120.153451.62650459.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:63385 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024Ab0ATXwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:52:51 -0500
Received: by fxm20 with SMTP id 20so762871fxm.1
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2010 15:52:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100120.153451.62650459.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2010 at 03:34:51PM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Thu, 21 Jan 2010 00:21:02 +0100
> 
> > "dma_sync_single_range(struct device *dev, dma_addr_t dma_handle,
> >                       unsigned long offset, size_t size,
> >                       enum dma_data_direction direction)
> > 
> > Does a partial sync, starting at offset and continuing for size.  You
> > must be careful to observe the cache alignment and width when doing
> > anything like this.  You must also be extra careful about accessing
> > memory you intend to sync partially." [Documentation/DMA-API.txt]
> > 
> > looks like even if implemented might be very tricky, especially if
> > untested.
> 
> This is an absurd set of requirements.  What driver author is
> going to get this right?
> 
> Any alignment issues are of the domain of the implementation and as
> Alan said should be handled there.
> 
> Back to the main issue, these localized fixes in the driver leave all
> of the other cases in the tree unhandled.  There are likely to be
> SCSI, USB host controller, SOUND, and other drivers with the same
> issue.
> 
> At what point do we understand that peppering workarounds in the
> drivers is the wrong way to go about this?

*Temporary* only workarounds. Mainly simple cases. (e.g. I'm not sure
of tg3)

> 
> Whereas 1 patch in the 1 place in the DMA API implementation would fix
> everything for everybody.

1) As I mentioned earlier there were similar dmar errors reported with
real oopses, but of course it might be unconnected. (But why risk...)

2) Why would the author of this doc above warn us so much if it were
so obviously simple and safe?

> 
> It's great that we had this report to track down the issue, now let's
> fix it correctly so nobody else (regardless of device they have) has
> to see it.

I hope you're right as usual! (But I disagree as usual ;-)

Jarek P.
