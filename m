From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH 1/5] initdev:kernel: Asynchronously-discovered device
 synchronization, v5
Date: Mon, 4 May 2009 11:07:52 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0905041100500.3092-100000@iolanthe.rowland.org>
References: <20090504074522.13f1ed77@infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>,
	David VomLehn <dvomlehn@cisco.com>,
	<linux-kernel@vger.kernel.org>, <akpm@linux-foundation.org>,
	<linux-usb@vger.kernel.org>, <greg@kroah.com>,
	<linux-scsi@vger.kernel.org>, <netdev@vger.kernel.org>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:56047 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754860AbZEDPHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 11:07:52 -0400
In-Reply-To: <20090504074522.13f1ed77@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 May 2009, Arjan van de Ven wrote:

> > > for normal device probing we already have infrastructure though...
> > > wait_for_device_probe, driver_probe_done and friends...
> > > (the scsi scanning thread is being converted to the async
> > > infrastructure btw)
> > > 
> > > do we need to invent more ?
> > 
> > I suppose the usb-storage scanning thread could also be converted to 
> > the async infrastructure, although I haven't heard of anybody working 
> > on it.
> > 
> > But the USB hub driver's thread (khubd) cannot be converted.  It is 
> > central to the discovery of USB-based block devices.  How would you 
> > handle that?
> 
> take a ref in the driver_probe_done() sense, and release it when you
> know you're done probing....
> 
> at that point all existing infrastructure will just work.

Isn't there still something missing?  The wait_for_device_probe()  
routine would wait until all attached devices had been probed.  But why
should prepare_namespace() have to wait that long?  Wouldn't it be
better to wait only until the root device has been registered?

Alan Stern

