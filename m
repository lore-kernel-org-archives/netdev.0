From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] usbnet: Fix two races between usbnet_stop() and the BH
Date: Mon, 24 Aug 2015 14:21:54 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1508241419170.5935-100000@iolanthe.rowland.org>
References: <Pine.LNX.4.44L0.1508241403100.5935-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eugene.shatokhin@rosalab.ru, <bjorn@mork.no>, <oneukum@suse.com>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1508241403100.5935-100000@iolanthe.rowland.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 24 Aug 2015, Alan Stern wrote:

> On Mon, 24 Aug 2015, David Miller wrote:
> 
> > From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
> > Date: Wed, 19 Aug 2015 14:59:01 +0300
> > 
> > > So the following might be possible, although unlikely:
> > > 
> > > CPU0             CPU1
> > >                  clear_bit: read dev->flags
> > >                  clear_bit: clear EVENT_RX_KILL in the read value
> > > 
> > > dev->flags=0;
> > > 
> > >                  clear_bit: write updated dev->flags
> > > 
> > > As a result, dev->flags may become non-zero again.
> > 
> > Is this really possible?
> > 
> > Stores really are "atomic" in the sense that the do their update
> > in one indivisible operation.
> 
> Provided you use ACCESS_ONCE or WRITE_ONCE or whatever people like to 
> call it now.
> 
> > Atomic operations like clear_bit also will behave that way.
> 
> Are you certain about that?  I couldn't find any mention of it in
> Documentation/atomic_ops.txt.
> 
> In theory, an architecture could implement atomic bit operations using 
> a spinlock to insure atomicity.  I don't know if any architectures do 
> this, but if they do then the scenario above could arise.

Now that I see this in writing, I realize it's not possible after all.  
clear_bit() et al. will work with a single unsigned long, which doesn't
leave any place for spinlocks or other mechanisms.  I was thinking of 
atomic_t.

So never mind...

Alan Stern
