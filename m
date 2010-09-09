From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/2] [RFC] posix clock tuning
Date: Thu, 9 Sep 2010 14:21:56 +0200
Message-ID: <20100909122156.GA2823@riccoc20.at.omicron.at>
References: <cover.1283504065.git.richard.cochran@omicron.at>
 <alpine.LFD.2.00.1009091152300.2477@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
To: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1009091152300.2477-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 09, 2010 at 11:58:09AM +0200, Thomas Gleixner wrote:
> On Fri, 3 Sep 2010, Richard Cochran wrote:
> 
> > Recently on the lkml, we discussed how to allow adjustment of posix
> > clocks. I have tried to understand and implement the ideas expressed
> > in the various threads.
> 
> Cc'ing the relevant maintainers to such discussions and patches might
> be helpful. Seems I need to do some archive digging.

Sorry about that. Still learning how to work on the list.  The story
so far is...

** PTP hardware clock as a character device (54 messages)

   http://lkml.org/lkml/2010/8/16/90

   The general mood of this was something like: "You have made a
   chardev for PTP clocks. The ioctls look similar to the posix clock
   api. Why not just use the posix api?"

** posix clock tuning syscall, static clockid (13 messages)

   http://lkml.org/lkml/2010/8/23/49

   The general mood of this one was: "I don't like a static clockid
   for PTP clocks. But a dynamic id would be just fine."

** posix clock tuning syscall, dynamic clockid (16 messages)

   http://lkml.org/lkml/2010/9/3/119 (This thread)

   The mood seems to be, "why not use a chardev for that?"

>From my point of view, the discussion is going round in circles. There
seems to be agreement that supporting PTP hardware clocks is a good
idea. The objections seem to be about the form of the API. In general,
there are three avenues.

1. character device (like hpet)
2. posix clock api
3. sysfs

Or possibly some combination of the three.

I have my preference, but I am willing to work it according to
taste. Would you have some preference?

> > If there is agreement on this approach, I will resubmit these two
> > patches as part of a longer series, including support for a new kind
> > of hardware clock, so you can see how it all fits together. But first,
> > I would like to concentrate on the new syscall itself.
> > 
> > The patches are against a recent net-next tree. Please don't worry if
> > the syscall tables are not quite up to date. I can fix that later.
> 
> How is this related to net-next ? 

The whole hardware timestamping and PTP clock issue is somewhat
network related. In particular, needed to start there to get some
background support for timestamping within PHY devices.

Thanks,

Richard
