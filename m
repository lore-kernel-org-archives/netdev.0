From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V8 08/13] posix clocks: cleanup the CLOCK_DISPTACH macro
Date: Thu, 13 Jan 2011 05:30:45 +0100
Message-ID: <20110113043037.GA17726@riccoc20.at.omicron.at>
References: <cover.1293820862.git.richard.cochran@omicron.at>
 <503cd1fa268867573001cfc9bb5681ee3b5b32fa.1293820862.git.richard.cochran@omicron.at>
 <alpine.LFD.2.00.1101111224280.12146@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>
To: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1101111224280.12146-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 11, 2011 at 01:57:23PM +0100, Thomas Gleixner wrote:
> 
> static clockid_t clock_get_array_id(const clockid_t id)
> {
> 	if (id >= 0)
> 	       return id < MAX_CLOCKS ? id : POSIX_INV_CLOCK_ID;
> 
>       	if (clock_is_posix_cpu(id))
> 		return POSIX_CPU_CLOCK_ID;
> 
> 	return POSIX_INV_CLOCK_ID;
> }
> 
> static inline int dispatch_clock_getres(const clockid_t id, struct timespec *ts)
> {
> 	struct k_clock *clk = &posix_clocks[clock_get_array_id(id)];
> 
> 	return clk->clock_getres ? clk->clock_getres(id, ts) : -EINVAL;
> }

I would like to take this idea one step further, like so:

static struct k_clock *clockid_to_kclock(const clockid_t id)
{
	if (id >= 0)
		return id < MAX_CLOCKS ?
			&posix_clocks[id] : &posix_clocks[POSIX_INV_CLOCK_ID];
	...
}

SYSCALL( ... , const clockid_t id, struct timespec *ts)
{
	struct k_clock *clk = clockid_to_kclock(id);

	return clk->clock_getres ? clk->clock_getres(id, ts) : -EINVAL;
}

What do you think?

Thanks,

Richard
