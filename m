From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Thu, 11 Oct 2012 11:05:48 +0200
Message-ID: <1940520.W6hRn23j86@linux-lqwf.site>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com> <1588459.VLxBbnNMlP@linux-lqwf.site> <CACVXFVPjx+053r_-QB=8kPCDmk3va3feN9MYdLgpf=eRWGe05A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVPjx+053r_-QB=8kPCDmk3va3feN9MYdLgpf=eRWGe05A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 11 October 2012 16:14:02 Ming Lei wrote:
> On Thu, Oct 11, 2012 at 12:11 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
> > On Thursday 11 October 2012 11:18:22 Ming Lei wrote:
> 
> >> Currently scsi disk can only be runtime suspended when the device is not
> >> opened, so are you sure that the paging out above can cause IO on a suspend
> >> usb mass storage disk which is not mounted or opened by utility now?
> >
> > We definitely do not wish to keep it that way. People at Intel are currently working
> > on better power management for sd, which would allow full autosuspend.
> 
> OK, got it.
> 
> For auto-resume situation, it can be solved with switching the gpf_t flag
> runtime inside helper, but I think it is better to do it after the sd's
> full autosuspend is seen in -next tree.

That depends on whether an API change would be necessary.
Changing the code only when necessary is no problem. But the
API I want to do right from the beginning if that is possible.

This depends on whether you get in your extension to task_struct.
If you do, we can certainly use it also for the suspend case.

> For error handling case, it is inevitably for usbnet to allocate memory
> with GFP_KERNEL because no usbnet drivers have implemented
> .pre_reset and .post_reset callback, and no such actual problems
> have been reported until now, so it should be OK to not consider the
> case now.
> 
> So could we merge the patch set[1-11] first?

Given the solution for error handling you came up with, yes, we can.
Would you resubmit?

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
