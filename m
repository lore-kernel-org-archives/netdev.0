From: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 07/19] timberdale: mfd_cell is now implicitly available
 to drivers
Date: Wed, 6 Apr 2011 11:38:54 -0700
Message-ID: <20110406183854.GA10058@suse.de>
References: <BANLkTi=bCd_+f=EG-O=U5VH_ZNjFhxkziQ@mail.gmail.com>
 <20110401235239.GE29397@sortiz-mobl>
 <BANLkTi=bq=OGzXFp7qiBr7x_BnGOWf=DRQ@mail.gmail.com>
 <20110404100314.GC2751@sortiz-mobl>
 <20110405030428.GB29522@ponder.secretlab.ca>
 <20110406152322.GA2757@sortiz-mobl>
 <20110406155805.GA20095@suse.de>
 <20110406170537.GB2757@sortiz-mobl>
 <20110406175647.GA8048@suse.de>
 <20110406112557.5c4c9bfe@debxo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
	khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org, ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org,
	Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>,
	Mauro Carvalho Chehab <mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Mocean Laboratories <info-l7gf1WXxx3uGw+nKnLezzg@public.gmane.org>
To: Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110406112557.5c4c9bfe@debxo>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 06, 2011 at 11:25:57AM -0700, Andres Salomon wrote:
> > > We've been faced with the problem of being able to pass both MFD
> > > related data and a platform_data pointer to some of those drivers.
> > > Squeezing the MFD bits in the sub driver platform_data pointer
> > > doesn't work for drivers that know nothing about MFDs. It also adds
> > > an additional dependency on the MFD API to all MFD sub drivers.
> > > That prevents any of those drivers to eventually be used as plain
> > > platform device drivers.
> > 
> > Then they shouldn't be "plain" platform drivers, that should only be
> > reserved for drivers that are the "lowest" type.  Just make them MFD
> > devices and go from there.
> 
> 
> The problem is of mixing "plain" platform devices and MFD devices.

Then don't do that.

> It's reasonable to assume that different hardware may be using
> one method or the other to create devices; in order to maintain
> compatibility with the driver, one either needs to use a plain platform
> device.  Alternatively, if an MFD-specific device class is created,
> then MFD devices would start showing up in weird places.

Then fix it.  Lots of other drivers handle different "bus types" just
fine (look at the EHCI USB driver for an example.)  Don't polute the
driver core just because you don't want to fix up the individual driver
issues that are quite obvious.

thanks,

greg k-h
