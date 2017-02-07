From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH net 1/4] pegasus: Use heap buffers for all register access
Date: Tue, 7 Feb 2017 12:24:12 +0200
Message-ID: <20170207102412.ljwcp5kcmhoagwfn@p310>
References: <20170204165451.GU3442@decadent.org.uk>
 <20170204165603.GV3442@decadent.org.uk>
 <20170205003038.GB21184@kroah.com>
 <20170206081444.smcgjkmdepxoosb6@p310>
 <20170206082822.GA23451@kroah.com>
 <20170206125108.d5vdur5rlvrkpr5j@localhost>
 <20170206132124.GA3038@localhost>
 <20170206133223.GC3038@localhost>
 <20170206134621.GD3038@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, Ben Hutchings <ben@decadent.org.uk>,
        netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        Lisandro =?utf-8?Q?Dami=C3=A1n_Nicanor_P=C3=A9rez?= Meyer
        <lisandro@debian.org>
To: Johan Hovold <johan@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:37218 "EHLO
        zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752149AbdBGKY0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 05:24:26 -0500
Content-Disposition: inline
In-Reply-To: <20170206134621.GD3038@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-06 14:46:21, Johan Hovold wrote:
> On Mon, Feb 06, 2017 at 02:32:23PM +0100, Johan Hovold wrote:
> > On Mon, Feb 06, 2017 at 02:21:24PM +0100, Johan Hovold wrote:
> > > On Mon, Feb 06, 2017 at 02:51:09PM +0200, Petko Manolov wrote:
> > > > On 17-02-06 09:28:22, Greg KH wrote:
> > > > > On Mon, Feb 06, 2017 at 10:14:44AM +0200, Petko Manolov wrote:
> > > 
> > > > > > Random thought: isn't it better to add the alloc/free code in 
> > > > > > usb_control_msg() and avoid code duplication all over the driver space?
> > > > > 
> > > > > A very long time ago we considered it, but realized that the majority of 
> > > > > drivers already had the memory dynamically allocated, so we just went with 
> > > > > this.  Perhaps we could revisit that if it turns out we were wrong, and would 
> > > > > simplify things.
> > > > 
> > > > A quick glance at usb_control_msg() users (looked only at .../net/usb and 
> > > > .../usb/serial) shows that most of them have the buffer allocated in stack.  
> > > 
> > > That's simply not true at all for usb-serial. If you find an instance
> > > were a stack allocated buffer is used for DMA that hasn't yet been
> > > fixed in USB serial, then please point it out so we can fix it up (I
> > > doubt you'll find one, though).
> > 
> > Heh, I just found one myself (in ark3116) that I'll fix up. Please let
> > me know if you find any more.
> 
> False alarm, the ark3116 driver is fine too.

You may want to check pl2303_vendor_read() in drivers/usb/serial/pl2303.c
It seems to me that 'buf' is allocated in the stack. ;)


		Petko
