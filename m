From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] posix clocks: introduce a syscall for clock tuning.
Date: Fri, 10 Sep 2010 11:23:03 +0200
Message-ID: <20100910092303.GA10179@riccoc20.at.omicron.at>
References: <cover.1283504065.git.richard.cochran@omicron.at>
 <7f4815cdfcf5bc49df4bdd09d59a4f56ca2598f5.1283504065.git.richard.cochran@omicron.at>
 <alpine.LFD.2.00.1009091159260.2477@localhost6.localdomain6>
 <20100909133449.GB2823@riccoc20.at.omicron.at>
 <alpine.LFD.2.00.1009092102150.2477@localhost6.localdomain6>
 <alpine.LFD.2.00.1009092244390.2477@localhost6.localdomain6>
 <1284072793.2762.259.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
To: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1284072793.2762.259.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 09, 2010 at 03:53:13PM -0700, john stultz wrote:
> The only problem there is from the examples, it seems some PTP hardware
> can be fairly self-contained. So its a actual ns clock that can be freq
> adjusted in hardware, not a constant freq counter that is then converted
> to nanoseconds and freq managed in software. So the interface probably
> can't be quite as low-level as the clocksource/clockevent structures.
> 
> In fact, from the example drivers posted already, it looks like the
> k_clock structure maps fairly close to what the hardware uses.

Yes, thats right. The PTP hardware clocks of which I know all follow
the same pattern.

> Other clock types that we may want to expose, such as the RTC also can
> map fairly close to k_clock. The audio clocks may need some research, as
> I suspect they're just a clocksource style counter, so some additional
> software cycle->ns layering similar to the timekeeping core (but likely
> much simpler) may be needed.

We may also find clocks that are free running counters which can
timestamp network packets. In that case, one would also need software
support to implement rate adjustment. I have not seen that yet among
PTP hardware clocks, so I think we should cross that bridge when we
come to it. In any case, the proposed infrastructure does not exclude
the possibility to support that kind of clock.

> So the question to Richard is, what does the above k_clock not provide
> that the PTP driver needs?

Yes.

> If you've already made some stabs at it,
> seeing an example of the generic header and a trivial example driver
> that includes the k_clock structure, so we can see what it removed from
> your earlier chardev implementation would be helpful.

Okay, it seems that we are gradually coming around to a workable
solution. I will repost the posix clock idea including the PTP clock
drivers, so you all can see how it would fit together.

Thanks,
Richard
