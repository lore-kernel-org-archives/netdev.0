From: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 07/19] timberdale: mfd_cell is now implicitly available
 to drivers
Date: Wed, 6 Apr 2011 15:09:00 -0700
Message-ID: <20110406220900.GA16117@suse.de>
References: <20110401235239.GE29397@sortiz-mobl>
 <BANLkTi=bq=OGzXFp7qiBr7x_BnGOWf=DRQ@mail.gmail.com>
 <20110404100314.GC2751@sortiz-mobl>
 <20110405030428.GB29522@ponder.secretlab.ca>
 <20110406152322.GA2757@sortiz-mobl>
 <20110406155805.GA20095@suse.de>
 <20110406170537.GB2757@sortiz-mobl>
 <20110406175647.GA8048@suse.de>
 <20110406184733.GD2757@sortiz-mobl>
 <20110406185902.GN25654@legolas.emea.dhcp.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
	khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org, ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org,
	Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>,
	Mauro Carvalho Chehab <mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Mocean Laboratories <info-l7gf1WXxx3uGw+nKnLezzg@public.gmane.org>
To: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110406185902.GN25654-UiBtZHVXSwEVvW8u9ZQWYwjfymiNCTlR@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 06, 2011 at 09:59:02PM +0300, Felipe Balbi wrote:
> Hi,
> 
> On Wed, Apr 06, 2011 at 08:47:34PM +0200, Samuel Ortiz wrote:
> > > > > What is a "MFD cell pointer" and why is it needed in struct device?
> > > > An MFD cell is an MFD instantiated device.
> > > > MFD (Multi Function Device) drivers instantiate platform devices. Those
> > > > devices drivers sometimes need a platform data pointer, sometimes an MFD
> > > > specific pointer, and sometimes both. Also, some of those drivers have been
> > > > implemented as MFD sub drivers, while others know nothing about MFD and just
> > > > expect a plain platform_data pointer.
> > > 
> > > That sounds like a bug in those drivers, why not fix them to properly
> > > pass in the correct pointer?
> > Because they're drivers for generic IPs, not MFD ones. By forcing them to use
> > MFD specific structure and APIs, we make it more difficult for platform code
> > to instantiate them.
> 
> I agree. What I do on those cases is to have a simple platform_device
> for the core IP driver and use platform_device_id tables to do runtime
> checks of the small differences. If one platform X doesn't use a
> platform_bus, it uses e.g. PCI, then you make a PCI "bridge" which
> allocates a platform_device with the correct name and adds that to the
> driver model.
> 
> See [1] (for the core driver) and [2] (for a PCI bridge driver) for an
> example of what I'm talking about.

Yes, thanks for providing a real example, this is the best way to handle
this.

thanks,

greg k-h
