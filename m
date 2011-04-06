From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 07/19] timberdale: mfd_cell is now implicitly available
 to drivers
Date: Wed, 6 Apr 2011 21:59:02 +0300
Message-ID: <20110406185902.GN25654@legolas.emea.dhcp.ti.com>
References: <BANLkTi=bCd_+f=EG-O=U5VH_ZNjFhxkziQ@mail.gmail.com>
 <20110401235239.GE29397@sortiz-mobl>
 <BANLkTi=bq=OGzXFp7qiBr7x_BnGOWf=DRQ@mail.gmail.com>
 <20110404100314.GC2751@sortiz-mobl>
 <20110405030428.GB29522@ponder.secretlab.ca>
 <20110406152322.GA2757@sortiz-mobl>
 <20110406155805.GA20095@suse.de>
 <20110406170537.GB2757@sortiz-mobl>
 <20110406175647.GA8048@suse.de>
 <20110406184733.GD2757@sortiz-mobl>
Reply-To: balbi-l0cyMroinI0@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>, Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
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
To: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110406184733.GD2757@sortiz-mobl>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Apr 06, 2011 at 08:47:34PM +0200, Samuel Ortiz wrote:
> > > > What is a "MFD cell pointer" and why is it needed in struct device?
> > > An MFD cell is an MFD instantiated device.
> > > MFD (Multi Function Device) drivers instantiate platform devices. Those
> > > devices drivers sometimes need a platform data pointer, sometimes an MFD
> > > specific pointer, and sometimes both. Also, some of those drivers have been
> > > implemented as MFD sub drivers, while others know nothing about MFD and just
> > > expect a plain platform_data pointer.
> > 
> > That sounds like a bug in those drivers, why not fix them to properly
> > pass in the correct pointer?
> Because they're drivers for generic IPs, not MFD ones. By forcing them to use
> MFD specific structure and APIs, we make it more difficult for platform code
> to instantiate them.

I agree. What I do on those cases is to have a simple platform_device
for the core IP driver and use platform_device_id tables to do runtime
checks of the small differences. If one platform X doesn't use a
platform_bus, it uses e.g. PCI, then you make a PCI "bridge" which
allocates a platform_device with the correct name and adds that to the
driver model.

See [1] (for the core driver) and [2] (for a PCI bridge driver) for an
example of what I'm talking about.

> The timberdale MFD for example is built with a Xilinx SPI controller, and a
> Micrel ks8842 ethernet switch IP. Forcing those devices into being MFD devices
> would mean any platform willing to instantiate them would have to use the MFD
> APIs. That sounds a bit artificial to me.

do they share any address space ? If they do, then you'd need something
to synchronize, right ? If they don't, then you just add two separate
devices, they don't have to be MFD.

> Although there is currently no drivers instantiated by both an MFD driver
> and some platform code, Grant complaint about the Xilinx SPI driver moving
> from a platform driver to an MFD one makes sense to me. 

I don't think so. That's not really an MFD device is it ? It's just two
different IPs instantianted on the same ASIC/FPGA, right ? Unless they
share the register space, IMHO, there's no need to make them MFD.

[1] http://gitorious.org/usb/usb/blobs/dwc3/drivers/usb/dwc3/core.c
[2] http://gitorious.org/usb/usb/blobs/dwc3/drivers/usb/dwc3/dwc3-haps.c

-- 
balbi
