From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
Date: Tue, 09 Sep 2008 15:30:10 +0100
Message-ID: <1220970610.2381.64.camel@achroite>
References: <1220960196-4209-1-git-send-email-steve.glendinning@smsc.com>
	 <1220960196-4209-2-git-send-email-steve.glendinning@smsc.com>
	 <1220966387.2381.42.camel@achroite>  <20080909140224.GA3095@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	linux-usb@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:51554 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751442AbYIIOaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 10:30:17 -0400
In-Reply-To: <20080909140224.GA3095@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-09-09 at 07:02 -0700, Greg KH wrote:
> On Tue, Sep 09, 2008 at 02:19:47PM +0100, Ben Hutchings wrote:
> > On Tue, 2008-09-09 at 12:36 +0100, Steve Glendinning wrote:
> > [...]
> > > diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> > > new file mode 100644
> > > index 0000000..60ffd90
> > > --- /dev/null
> > > +++ b/drivers/net/usb/smsc95xx.c
> > [...]
> > > +static int smsc95xx_read_reg(struct usbnet *dev, u32 index, u32 *data)
> > > +{
> > > +	u32 *buf = kmalloc(4, GFP_KERNEL);
> > > +	int ret;
> > > +
> > > +	BUG_ON(!dev);
> > > +
> > > +	if (!buf)
> > > +		return -ENOMEM;
> > > +
> > > +	ret = usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
> > > +		USB_VENDOR_REQUEST_READ_REGISTER,
> > > +		USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
> > > +		00, index, buf, 4, USB_CTRL_GET_TIMEOUT);
> > > +
> > > +	if (unlikely(ret < 0))
> > > +		SMSC_WARNING("Failed to read register index 0x%08x", index);
> > > +
> > > +	le32_to_cpus(buf);
> > > +	*data = *buf;
> > > +	kfree(buf);
> > > +
> > > +	return ret;
> > > +}
> > 
> > Why are you allocating a buffer on the heap?  What's wrong with
> 
> USB requires data to be allocated off of the heap when you use it to
> send or receive data.

I don't really know USB (it's not very useful for 1G/10G networking :-)
which is why I asked.  Is this because the data may be transferred by
DMA and the stack might not be DMA-mappable?

I'd be inclined to allocate a persistent buffer for register reads and
writes, but then that seems to introduce the need for another lock.
Presumably the heap allocation is reckoned to add very little overhead
compared to the inherent cost of synchronous USB requests?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

