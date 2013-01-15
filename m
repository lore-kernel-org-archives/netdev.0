From: horseriver <horserivers@gmail.com>
Subject: Re: what is the use of poll function int a net_device struct
Date: Tue, 15 Jan 2013 08:52:47 +0800
Message-ID: <20130115005247.GB18654@debian.localdomain>
References: <20130114142136.GA17094@debian.localdomain>
 <CAKoUArmq0+aMdMyDvRu+fCJXynrqywpeJiajG=84YCxdFV-GKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f52.google.com ([209.85.210.52]:40469 "EHLO
	mail-da0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932075Ab3APE0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 23:26:11 -0500
Received: by mail-da0-f52.google.com with SMTP id f10so374015dak.11
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 20:26:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAKoUArmq0+aMdMyDvRu+fCJXynrqywpeJiajG=84YCxdFV-GKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 15, 2013 at 03:20:39PM +0200, Rami Rosen wrote:
> Hi,
> 
> On Mon, Jan 14, 2013 at 4:21 PM, horseriver <horserivers@gmail.com> wrote:
> > Where is the handler function defined  for an netcard's  IRQ
> 
> look for the request_irq() method; you register the handler with this method.
> 
> for example,
> in e1000e:
> 
> http://lxr.free-electrons.com/source/drivers/net/ethernet/intel/e1000e/netdev.c
> 
> err = request_irq(adapter->msix_entries[vector].vector,
>                            e1000_intr_msix_rx, 0,
>                           adapter->rx_ring->name,
>                              netdev);
> 
> so the handler is   e1000_intr_msix_rx().
> 
> When an IRQ has reached,  how to wake_up the wait_queue of the socket?
> TCP/UDP packet goes up from the driver to L3 and then to L4 (in case
> it is for this machine). In L4 you should find the
> wake_up of the wait_queue of the socket.
  
  thanks!
  
  In L4, wake_up should be fired  by IRQ event.
  where is the code for fire this callback ?

  

> 
> Regards,
> Rami Rosen
> http://ramirose.wix.com/ramirosen
