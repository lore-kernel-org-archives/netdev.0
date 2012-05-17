From: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [RFC 13/13] USB: Disable hub-initiated LPM for comms devices.
Date: Thu, 17 May 2012 07:49:51 -0700
Message-ID: <20120517144951.GB27597@kroah.com>
References: <cover.1337203535.git.sarah.a.sharp@linux.intel.com>
 <20120516224528.GA25936@xanatos>
 <20120516232019.GA960@kroah.com>
 <20120517045220.GA4772@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gigaset307x-common-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
To: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120517045220.GA4772@xanatos>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, May 16, 2012 at 09:52:20PM -0700, Sarah Sharp wrote:
> On Wed, May 16, 2012 at 04:20:19PM -0700, Greg Kroah-Hartman wrote:
> > On Wed, May 16, 2012 at 03:45:28PM -0700, Sarah Sharp wrote:
> > > [Resending with a smaller Cc list]
> > > 
> > > Hub-initiated LPM is not good for USB communications devices.  Comms
> > > devices should be able to tell when their link can go into a lower power
> > > state, because they know when an incoming transmission is finished.
> > > Ideally, these devices would slam their links into a lower power state,
> > > using the device-initiated LPM, after finishing the last packet of their
> > > data transfer.
> > > 
> > > If we enable the idle timeouts for the parent hubs to enable
> > > hub-initiated LPM, we will get a lot of useless LPM packets on the bus
> > > as the devices reject LPM transitions when they're in the middle of
> > > receiving data.  Worse, some devices might blindly accept the
> > > hub-initiated LPM and power down their radios while they're in the
> > > middle of receiving a transmission.
> > > 
> > > The Intel Windows folks are disabling hub-initiated LPM for all USB
> > > communications devices under a xHCI USB 3.0 host.  In order to keep
> > > the Linux behavior as close as possible to Windows, we need to do the
> > > same in Linux.
> > 
> > How is the USB core on Windows determining that LPM should be turned off
> > for these devices?  Surely they aren't modifying each individual driver
> > like this is, right?  Any way we also can do this in the core?
> 
> No, I don't think they're modifying individual drivers.  Maybe they
> placed a shim/filter driver below other drivers?

They can do this in their driver by just watching the device class type.

> Basically, I don't know the exact details of what the Windows folks are
> doing.  The recommendation from the Intel Windows team was simply to
> turn hub-initiated LPM off for "all communications devices".  Perhaps
> the Windows USB core is looking for specific USB class codes?  Or maybe
> it has some older API that lets the core know it's a communications
> device?
> 
> I'm not really sure we can do it in the USB core with out basically
> duplicating all the class/PID/VID matching in the communications driver.
> I think just adding a flag might be the best way.  I'm open to
> suggestions though.

You can detect something as "simple" as a class type, which I bet is all
that Windows is going to be able to do as well.

> > Or, turn it around the other way, and only enable it if we know it's
> > safe to do so, in each driver, but I guess that would be even messier.
> 
> Yeah, I think it would be messier.

Ok, this is probably the best solution for us as well, sorry for the
noise.

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
