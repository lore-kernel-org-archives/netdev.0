From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH] Extend lock less TX to real devices
Date: 4 Sep 2004 15:28:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040904132809.GB33964@muc.de>
References: <m38ybvjxdv.fsf@averell.firstfloor.org> <20040901223301.1a8d97a8.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Sat, 4 Sep 2004 15:28:09 +0200
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040901223301.1a8d97a8.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 01, 2004 at 10:33:01PM -0700, David S. Miller wrote:
> On Tue, 31 Aug 2004 14:38:20 +0200
> Andi Kleen <ak@muc.de> wrote:
> 
> > This patch extends the recently added NETIF_F_LLTX to real devices.
> 
> Well, it does a lot of other things too.

Not really, it all works to the same goal.

> 
> > I added support for trylocking instead of spinning like sch_generic
> > does - for that the driver has to return -1, then the packet is requeued.
> > The check for a local device deadlock is lost for this case, 
> > but that doesn't seem to be a big loss (I've never seen this printk 
> > ever get triggered)
> 
> It is triggerable if you misconfigure your system.

Really? The only reason I can see for it is a buggy driver.

> I'm totally against this change, because previously at

There is no change, except for drivers that set LLTX
and these get different semantics anyways because they
have to handle this on their own.  In case the driver
has bugs I guess it would be better to add the printk
directly below the try_lock in the LLTX driver.

> least the user would find out in their logs.  With your
> change the system explodes looping with no explanation why.

Hmm, I guess if you're really worried about this class
of driver bugs being common adding some real error handling
for it (like bailing out and disabling the device) would
be the far better option.

> 
> > The patch looks bigger than it really is because i moved some code
> > around and converted the macros into inlines. 
>  ..
> > I also did an additional micro optimization:
> 
> And for this reason you need to split this patch up.
> I would recommend:
> 
> patch 1) Change macros into inlines
> patch 2) local_bh_disable() preemption count optimization
> patch 3) support for F_LLTX on real devices
> patch 4) locking changes

At least (3) and (4) are the same thing. I can drop the 
inlines, it was only for making the code clearer and less ugly
but is not essential for the optimizations.

-Andi
