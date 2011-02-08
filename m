From: Andreas Mohr <andi-5+Cda9B46AM@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 28532] New: Link state change detection problem
 on Moschip MCS7832 [mcs7830]
Date: Tue, 8 Feb 2011 21:52:47 +0100
Message-ID: <20110208205247.GA4617@rhlx01.hs-esslingen.de>
References: <bug-28532-10286@https.bugzilla.kernel.org/>
 <20110207151401.d1db088a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, myxal.mxl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Andreas Mohr <andi-5+Cda9B46AM@public.gmane.org>
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110207151401.d1db088a.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

> > I have a network adapter which uses the aforementioned driver and while
> > checking for the link state via ethtool reports the correct state, many
> > networking userspace utilities seem to have no clue about it (NM 0.8.1 starts
> > dhclient BEFORE any cable is plugged) - and more importantly, don't notice when
> > the cable is (dis)connected. Since there's not even a kernel message when
> > (dis)connecting the cable, I suspect the driver does not implement Link state
> > change detection at all. Is this accurate?

Ah, perhaps that is why as long as network-mangler is running, my
.resume_reset() handler improvements (managing to keep an active interface
even directly after resume) actually do _not_ work (since it seems it simply
down:s the iface and that's it).
I know that there is link info functionality in other drivers yet not
as much in mcs7830.

Note that the mcs7830 driver still has a rather stubby appearance
(many more "advanced" features are either weak or not available at all).

I've got a patch series sitting here to improve several parts
(and waiting to cook a bit more), but I hadn't even identified the link issue.
It appears that this would need fixing, presto.

> > LSCD works in Windows, where it's apparently implemented through periodic
> > polling (judging by virtualbox's blinking USB icon).
> > How is this situation normally handled? Is it kernel's job to do the polling?
> > Or are userspace utilities expected to do this?

I'm afraid a painful solution would be to activate the .status callback
for periodic USB status descriptor polling. I've got a
half-implementation of that, however it's very painful in terms of
obscene amounts of CPU wakeups.
There _has_ to be a better solution...

Thank you for your (the OP's) report (and for my extra notification!),
this seems very helpful!
(I am determined to post related useful patches soon,
especially since this card is in active use here)

Andreas Mohr
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
