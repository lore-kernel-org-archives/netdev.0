From: Petko Manolov <petkan-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH net 1/4] pegasus: Use heap buffers for all register access
Date: Tue, 7 Feb 2017 14:50:13 +0200
Message-ID: <20170207125013.imorls2ows2ukqdk@p310>
References: <20170204165603.GV3442@decadent.org.uk>
 <20170205003038.GB21184@kroah.com>
 <20170206081444.smcgjkmdepxoosb6@p310>
 <20170206082822.GA23451@kroah.com>
 <20170206125108.d5vdur5rlvrkpr5j@localhost>
 <20170206132124.GA3038@localhost>
 <20170206133223.GC3038@localhost>
 <20170206134621.GD3038@localhost>
 <20170207102412.ljwcp5kcmhoagwfn@p310>
 <20170207104506.GB32583@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Lisandro =?utf-8?Q?Dami=C3=A1n_Nicanor_P=C3=A9rez?= Meyer
        <lisandro-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170207104506.GB32583-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 17-02-07 11:45:06, Greg KH wrote:
> On Tue, Feb 07, 2017 at 12:24:12PM +0200, Petko Manolov wrote:
> > On 17-02-06 14:46:21, Johan Hovold wrote:
> > > On Mon, Feb 06, 2017 at 02:32:23PM +0100, Johan Hovold wrote:
> > > > On Mon, Feb 06, 2017 at 02:21:24PM +0100, Johan Hovold wrote:
> > > > > On Mon, Feb 06, 2017 at 02:51:09PM +0200, Petko Manolov wrote:
> > > > > > On 17-02-06 09:28:22, Greg KH wrote:
> > > > > > > On Mon, Feb 06, 2017 at 10:14:44AM +0200, Petko Manolov wrote:
> > > > > 
> > > > > > > > Random thought: isn't it better to add the alloc/free code in 
> > > > > > > > usb_control_msg() and avoid code duplication all over the driver space?
> > > > > > > 
> > > > > > > A very long time ago we considered it, but realized that the majority of 
> > > > > > > drivers already had the memory dynamically allocated, so we just went with 
> > > > > > > this.  Perhaps we could revisit that if it turns out we were wrong, and would 
> > > > > > > simplify things.
> > > > > > 
> > > > > > A quick glance at usb_control_msg() users (looked only at .../net/usb and 
> > > > > > .../usb/serial) shows that most of them have the buffer allocated in stack.  
> > > > > 
> > > > > That's simply not true at all for usb-serial. If you find an instance
> > > > > were a stack allocated buffer is used for DMA that hasn't yet been
> > > > > fixed in USB serial, then please point it out so we can fix it up (I
> > > > > doubt you'll find one, though).
> > > > 
> > > > Heh, I just found one myself (in ark3116) that I'll fix up. Please let
> > > > me know if you find any more.
> > > 
> > > False alarm, the ark3116 driver is fine too.
> > 
> > You may want to check pl2303_vendor_read() in drivers/usb/serial/pl2303.c
> > It seems to me that 'buf' is allocated in the stack. ;)
> 
> Really?  Doesn't look like it to me, it's passed in from the caller and it's 
> allocated in that caller.  What am I missing here?

Sorry, got confused by the weird pointer definition of the last argument:

static int pl2303_vendor_read(struct usb_serial *serial, u16 value, unsigned char buf[1])


cheers,
Petko
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
