From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/11] sky2: fix DMA sync_single length error
Date: Wed, 20 Jan 2010 15:34:51 -0800 (PST)
Message-ID: <20100120.153451.62650459.davem@davemloft.net>
References: <20100120213259.GB3072@del.dom.local>
	<20100120.145218.259766536.davem@davemloft.net>
	<20100120232102.GD3072@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49119
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751626Ab0ATXel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:34:41 -0500
In-Reply-To: <20100120232102.GD3072@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 21 Jan 2010 00:21:02 +0100

> "dma_sync_single_range(struct device *dev, dma_addr_t dma_handle,
>                       unsigned long offset, size_t size,
>                       enum dma_data_direction direction)
> 
> Does a partial sync, starting at offset and continuing for size.  You
> must be careful to observe the cache alignment and width when doing
> anything like this.  You must also be extra careful about accessing
> memory you intend to sync partially." [Documentation/DMA-API.txt]
> 
> looks like even if implemented might be very tricky, especially if
> untested.

This is an absurd set of requirements.  What driver author is
going to get this right?

Any alignment issues are of the domain of the implementation and as
Alan said should be handled there.

Back to the main issue, these localized fixes in the driver leave all
of the other cases in the tree unhandled.  There are likely to be
SCSI, USB host controller, SOUND, and other drivers with the same
issue.

At what point do we understand that peppering workarounds in the
drivers is the wrong way to go about this?

Whereas 1 patch in the 1 place in the DMA API implementation would fix
everything for everybody.

It's great that we had this report to track down the issue, now let's
fix it correctly so nobody else (regardless of device they have) has
to see it.
