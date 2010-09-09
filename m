From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [PATCH 0/2] [RFC] posix clock tuning
Date: Thu, 9 Sep 2010 16:02:17 +0100
Message-ID: <20100909160217.59f9c491@lxorguk.ukuu.org.uk>
References: <cover.1283504065.git.richard.cochran@omicron.at>
	<alpine.LFD.2.00.1009091152300.2477@localhost6.localdomain6>
	<20100909122156.GA2823@riccoc20.at.omicron.at>
	<alpine.LFD.2.00.1009091443250.2477@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
To: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.2.00.1009091443250.2477-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > 1. character device (like hpet)
> > 2. posix clock api
> > 3. sysfs
> > 
> > Or possibly some combination of the three.
> 
> I fail to see the requirement for any of those. Either the hardware
> clock is suitable as a clocksource for general consumption, then it
> should just be used as a clock source. If it's not - e.g. because it's
> too slow to access - then it just should serve as a reference in the
> NTP style and steer the timekeeping into sync.

I think you are confusing clocks, time stamps and the system time.

System time is a single default reference source defined by POSIX in
terms of sort of UTC.

There are lots of other time sources which don't necessarily tally with
oen another and there are times you have to respect more than one of them
because you are not the master clock nor can you dictate synchronization
between the two pieces of infrastructure you span

Consider a large rock gig - your control systems for the speakers and PA
are tightly synchronized and delivering audio with very precise delays to
different amp/speaker combinations. At the same time if you are managing
effects and the like then the instrument timings for those will be coming
off another clock, which is also very precise and differently sourced.

So what we actually have is

- multiple input devices that report timestamps (the PC clock, GPS, PTP,
  time synchronized busses, synchronous ethernet, network provided reports
  etc)

- some of those inputs get turned into clocks with varying degrees of
  hardware and software processing which are consumed by various bits of
  software and drivers

- a subset of those clocks in some form are algmated into a generic
  system time. which provides a meaningful representation of general time
  to the majority of apps that simple can't care less

Apps and drivers need access to all three layers.
