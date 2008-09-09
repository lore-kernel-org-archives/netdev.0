From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/1] SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
Date: Tue, 9 Sep 2008 07:02:24 -0700
Message-ID: <20080909140224.GA3095@kroah.com>
References: <1220960196-4209-1-git-send-email-steve.glendinning@smsc.com> <1220960196-4209-2-git-send-email-steve.glendinning@smsc.com> <1220966387.2381.42.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	linux-usb@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:43129 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594AbYIIODJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 10:03:09 -0400
Content-Disposition: inline
In-Reply-To: <1220966387.2381.42.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 09, 2008 at 02:19:47PM +0100, Ben Hutchings wrote:
> On Tue, 2008-09-09 at 12:36 +0100, Steve Glendinning wrote:
> [...]
> > diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> > new file mode 100644
> > index 0000000..60ffd90
> > --- /dev/null
> > +++ b/drivers/net/usb/smsc95xx.c
> [...]
> > +static int smsc95xx_read_reg(struct usbnet *dev, u32 index, u32 *data)
> > +{
> > +	u32 *buf = kmalloc(4, GFP_KERNEL);
> > +	int ret;
> > +
> > +	BUG_ON(!dev);
> > +
> > +	if (!buf)
> > +		return -ENOMEM;
> > +
> > +	ret = usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
> > +		USB_VENDOR_REQUEST_READ_REGISTER,
> > +		USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
> > +		00, index, buf, 4, USB_CTRL_GET_TIMEOUT);
> > +
> > +	if (unlikely(ret < 0))
> > +		SMSC_WARNING("Failed to read register index 0x%08x", index);
> > +
> > +	le32_to_cpus(buf);
> > +	*data = *buf;
> > +	kfree(buf);
> > +
> > +	return ret;
> > +}
> 
> Why are you allocating a buffer on the heap?  What's wrong with

USB requires data to be allocated off of the heap when you use it to
send or receive data.

> static int smsc95xx_read_reg(struct usbnet *dev, u32 index, u32 *data)

Is data always allocated off of the heap here?

thanks,

greg k-h
