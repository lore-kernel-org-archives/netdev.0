From: 'Greg KH' <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net 2/4] rtl8150: Use heap buffers for all register access
Date: Tue, 7 Feb 2017 13:42:04 +0100
Message-ID: <20170207124204.GA11883@kroah.com>
References: <20170204165451.GU3442@decadent.org.uk>
 <20170204165631.GW3442@decadent.org.uk>
 <063D6719AE5E284EB5DD2968C1650D6DB027CA6E@AcuExch.aculab.com>
 <20170206162520.GA3442@decadent.org.uk>
 <20170207103452.zb4frzltpdjaaf2s@p310>
 <20170207105131.GA2700@kroah.com>
 <063D6719AE5E284EB5DD2968C1650D6DB027DB75@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Petko Manolov <petkan-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org>,
        Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB027DB75-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 07, 2017 at 11:56:51AM +0000, David Laight wrote:
> From: Greg KH
> > Sent: 07 February 2017 10:52
> > To: Petko Manolov
> > Cc: Ben Hutchings; David Laight; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Subject: Re: [PATCH net 2/4] rtl8150: Use heap buffers for all register access
> > 
> > On Tue, Feb 07, 2017 at 12:34:52PM +0200, Petko Manolov wrote:
> > > On 17-02-06 16:25:20, Ben Hutchings wrote:
> > > > On Mon, Feb 06, 2017 at 04:09:18PM +0000, David Laight wrote:
> > > > > From: Ben Hutchings
> > > > [...]
> > > > > > +	ret = usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
> > > > > > +			      RTL8150_REQ_GET_REGS, RTL8150_REQT_READ,
> > > > > > +			      indx, 0, buf, size, 500);
> > > > > > +	if (ret > 0 && ret <= size)
> > > > > > +		memcpy(data, buf, ret);
> > > > >
> > > > > If ret > size something is horridly wrong.
> > > > > Silently not updating the callers buffer at all cannot be right.
> > > >
> > > > Yes, it seems strange to check this.  I originally wrote this as ret >
> > > > 0, but then I checked the usbnet core and found __usbnet_read_cmd()
> > > > has the second comparison as well.
> > > >
> > > > > > +	kfree(buf);
> > > > > > +	return ret;
> > >
> > > Since we return what usb_control_msg() told us to return i assume the error code
> > > will be available to anybody who cares.
> > >
> > > > > I can't help feeling that it would be better to add a wrapper to
> > > > > usb_control_msg() that does the kmalloc() and memcpy()s and
> > > > > drop that into all the call sites.
> > > >
> > > > It might be.  Right now I'm trying to patch up a bunch of regressions rather
> > > > than argue over an API change.
> > >
> > > Right, first thing first.
> > >
> > > I am in favor of changing the API, but this should not happen in the stable
> > > releases.  I hope Greg will make up his mind and let us know.
> > 
> > make up my mind about what?  These are bugs, they should be fixed, I'm
> > not taking a total api change at this point in time, sorry.
> 
> Adding a usb_control_msg_with_malloc() wrapper is a smaller change than those
> proposed. The smaller churn probably makes back porting other changes easier.
> 
> Given the nature of this problem, and how common it seems to be,
> it is almost worth renaming usb_control_msg() itself so that all the
> callers are properly audited.

As this is something that we have been auditing for a decade now, I
don't think you will find all that many instances :)

But for now, fixes like this are fine, if someone wants to tackle the
larger issue here, with a new api function, that would be great.

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
