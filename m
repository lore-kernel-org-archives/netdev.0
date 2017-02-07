From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH net 2/4] rtl8150: Use heap buffers for all register access
Date: Tue, 7 Feb 2017 11:51:31 +0100
Message-ID: <20170207105131.GA2700@kroah.com>
References: <20170204165451.GU3442@decadent.org.uk>
 <20170204165631.GW3442@decadent.org.uk>
 <063D6719AE5E284EB5DD2968C1650D6DB027CA6E@AcuExch.aculab.com>
 <20170206162520.GA3442@decadent.org.uk>
 <20170207103452.zb4frzltpdjaaf2s@p310>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>,
        David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:47813 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751094AbdBGKvc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 05:51:32 -0500
Content-Disposition: inline
In-Reply-To: <20170207103452.zb4frzltpdjaaf2s@p310>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2017 at 12:34:52PM +0200, Petko Manolov wrote:
> On 17-02-06 16:25:20, Ben Hutchings wrote:
> > On Mon, Feb 06, 2017 at 04:09:18PM +0000, David Laight wrote:
> > > From: Ben Hutchings
> > [...]
> > > > +	ret = usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
> > > > +			      RTL8150_REQ_GET_REGS, RTL8150_REQT_READ,
> > > > +			      indx, 0, buf, size, 500);
> > > > +	if (ret > 0 && ret <= size)
> > > > +		memcpy(data, buf, ret);
> > > 
> > > If ret > size something is horridly wrong.
> > > Silently not updating the callers buffer at all cannot be right.
> > 
> > Yes, it seems strange to check this.  I originally wrote this as ret >
> > 0, but then I checked the usbnet core and found __usbnet_read_cmd()
> > has the second comparison as well.
> > 
> > > > +	kfree(buf);
> > > > +	return ret;
> 
> Since we return what usb_control_msg() told us to return i assume the error code 
> will be available to anybody who cares.
> 
> > > I can't help feeling that it would be better to add a wrapper to
> > > usb_control_msg() that does the kmalloc() and memcpy()s and
> > > drop that into all the call sites.
> > 
> > It might be.  Right now I'm trying to patch up a bunch of regressions rather 
> > than argue over an API change.
> 
> Right, first thing first.
> 
> I am in favor of changing the API, but this should not happen in the stable 
> releases.  I hope Greg will make up his mind and let us know.

make up my mind about what?  These are bugs, they should be fixed, I'm
not taking a total api change at this point in time, sorry.

greg k-h
