From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: RE: [PATCH] lan78xx: Protect runtime_auto check by #ifdef CONFIG_PM
Date: Mon, 21 Mar 2016 17:02:30 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1603211701190.1708-100000@iolanthe.rowland.org>
References: <9235D6609DB808459E95D78E17F2E43D404CC1EF@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: oneukum-IBi9RG/b67k@public.gmane.org, <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
	<UNGLinuxDriver-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>, <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Woojung.Huh-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D404CC1EF-8fD0d2gESGrABDY0R+s2SH2Vsf1/G1/XQQ4Iyu8u01E@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Mar 2016 Woojung.Huh-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org wrote:

> > > > But this leaves open the issue that querying the device too often will
> > > > prevent it from going into autosuspend.  It seems to me that the best
> > > > way to deal with this is to make sure that the autosuspend timeout is
> > > > shorter than the interal between queries, not to make the querying
> > > > conditional on !runtime_auto.
> > >
> > > Short autosuspend timeout can affect performance. For instance our
> > experiments showed that
> > > shorter than 10sec timeout made Ethernet performance degrade because
> > of wakeup delays.
> > > So, just putting shorter timeout may have some side effects.
> > 
> > Sure.  This just means that you need a long statistics interval --
> > longer than the autosuspend timeout.  That's why I suggested making the
> > interval adjustable.
> 
> What do you mean statistics interval?
> Interval calling ndo_get_stats64 or another thread/timer or else getting statistics?

The time between calls to ndo_get_stats64, since that's the routine 
which queries the device.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
