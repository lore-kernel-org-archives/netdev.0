From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [PATCH 07/19] timberdale: mfd_cell is now implicitly available
 to drivers
Date: Thu, 7 Apr 2011 01:04:04 -0700
Message-ID: <20110407080404.GF6427@angua.secretlab.ca>
References: <20110401235239.GE29397@sortiz-mobl>
 <BANLkTi=bq=OGzXFp7qiBr7x_BnGOWf=DRQ@mail.gmail.com>
 <20110404100314.GC2751@sortiz-mobl>
 <20110405030428.GB29522@ponder.secretlab.ca>
 <20110406152322.GA2757@sortiz-mobl>
 <20110406155805.GA20095@suse.de>
 <20110406170537.GB2757@sortiz-mobl>
 <20110406175647.GA8048@suse.de>
 <20110406112557.5c4c9bfe@debxo>
 <20110406183854.GA10058@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
	khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org, ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org,
	Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>,
	Mauro Carvalho Chehab <mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Mocean Laboratories <info-l7gf1WXxx3uGw+nKnLezzg@public.gmane.org>
To: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110406183854.GA10058-l3A5Bk7waGM@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 06, 2011 at 11:38:54AM -0700, Greg KH wrote:
> On Wed, Apr 06, 2011 at 11:25:57AM -0700, Andres Salomon wrote:
> > > > We've been faced with the problem of being able to pass both MFD
> > > > related data and a platform_data pointer to some of those drivers.
> > > > Squeezing the MFD bits in the sub driver platform_data pointer
> > > > doesn't work for drivers that know nothing about MFDs. It also adds
> > > > an additional dependency on the MFD API to all MFD sub drivers.
> > > > That prevents any of those drivers to eventually be used as plain
> > > > platform device drivers.
> > > 
> > > Then they shouldn't be "plain" platform drivers, that should only be
> > > reserved for drivers that are the "lowest" type.  Just make them MFD
> > > devices and go from there.
> > 
> > 
> > The problem is of mixing "plain" platform devices and MFD devices.
> 
> Then don't do that.

>From my perspective, MFD devices are little more than a bag of
platform_devices, with the MFD layer provides infrastructure for
managing it.  It isn't that there are 'plain' platform device and
'mfd' devices.  There are only platform_devices, but some of the
drivers use additional data stored in a struct mfd.

Personally, I'm not thrilled with the approach of using struct mfd, or
more specifically making it available to drivers, but on the ugly
scale it isn't very high.

However, the changes on how struct mfd is passed that were merged in
2.6.39 were actively dangerous and are going to be reverted.  Yet
a method is still needed to pass the struct mfd in a safe way.  I
don't have a problem with adding the mfd pointer to struct
platform_device, even if it should just be a stop gap to something
better.

Independently, I have been experimenting with typesafe methods for
attaching data to devices which may very well be the long term
approach, but for the short term I see no problem with adding the mfd
pointer, particularly because it is by far safer than any of the other
immediately available options.

g.
