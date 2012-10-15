From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Mon, 15 Oct 2012 10:27:19 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1210151018260.1702-100000@iolanthe.rowland.org>
References: <15188898.QK0YCDZ0MW@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<jkosina-IBi9RG/b67k@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <15188898.QK0YCDZ0MW-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Oct 2012, Oliver Neukum wrote:

> On Friday 12 October 2012 11:29:49 Alan Stern wrote:
> > On Fri, 12 Oct 2012, Oliver Neukum wrote:
> 
> > > First we have workqueues. bas-gigaset is a good example.
> > > The driver kills a scheduled work in pre_reset(). If this is done synchronously
> > > the driver may need to wait for a memory allocation inside the work.
> > > In principle we could provide a workqueue limited to GFP_NOIO. Is that worth
> > > it, or do we just check?
> > 
> > The work routine could set the GFP mask upon entry and exit.  Then a 
> > separate workqueue wouldn't be needed.
> 
> Well, yes. But if we have to touch the code we might just as well use GFP-NOIO

Depends on what the code does.  If it does very little requiring memory 
allocation then yes, you could simply use GFP_NOIO.  But if it calls 
lots of other routines that all do their own allocation, setting the 
mask will be better.

> > > I am afraid there is no generic solution in the last two cases. What do you think?
> > 
> > The other contexts must also set the GFP mask.  Unfortunately, this has 
> > to be done case-by-case.
> 
> This raises a question. If we do the port-power-off stuff, does reset_resume() of every
> device under the depowered port have to be called?

Certainly.

>  If so, we cannot exclude vendor
> specific drivers from the audit, can we?

True.  But hasn't that always been the case?  A device could need a 
vendor-specific driver for one interface while another interface uses a 
standard mass-storage protocol.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
