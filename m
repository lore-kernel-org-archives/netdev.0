From: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [RFC 13/13] USB: Disable hub-initiated LPM for comms devices.
Date: Thu, 17 May 2012 10:31:50 -0700
Message-ID: <20120517173150.GE4967@xanatos>
References: <cover.1337203535.git.sarah.a.sharp@linux.intel.com>
 <3c634afbbe15598cdcbf77bb9393d22ad4bfa373.1337203535.git.sarah.a.sharp@linux.intel.com>
 <4FB53054.9070309@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Hansjoerg Lipp <hjlipp-S0/GAf8tV78@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gigaset307x-common-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
To: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4FB53054.9070309-ZTO5kqT2PaM@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 17, 2012 at 07:07:32PM +0200, Tilman Schmidt wrote:
> Am 16.05.2012 23:55, schrieb Sarah Sharp:
> > Set the disable_hub_initiated_lpm flag for for all USB communications
> > drivers.  I know there aren't currently any USB 3.0 devices that
> > implement these class specifications, but we should be ready if they do.
> 
> I follow the argument for class drivers. But this patch also
> modifies drivers for specific existing USB 2.0 only devices
> which are unlikely to ever grow USB 3.0 support, such as the
> Gigaset ISDN driver:
> 
> >  drivers/isdn/gigaset/bas-gigaset.c            |    1 +
> >  drivers/isdn/gigaset/usb-gigaset.c            |    1 +

Is there a particular reason why you think that driver is unlikely to
ever get USB 3.0 support?  I pretty much grabbed any USB driver that
looked like a communications driver without looking too closely at the
code.

> What is the interest of setting the disable_hub_initiated_lpm
> flag for these?

It's partially to lay the foundation for anyone who wants to make a USB
3.0 communications driver in the future.  They're likely to start from
some USB 2.0 class driver, and copy a lot of code.  If they notice that
flag is set in all the USB communications class drivers, they're likely
to set it as well.

I'm not quite sure where the best place to provide documentation on the
flag is.  I've added the kernel doc comments to the structure, but maybe
it needs to be documented somewhere in Documentation/usb/?

Sarah Sharp
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
