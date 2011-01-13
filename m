From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: [PATCH V9 08/13] posix clocks: cleanup the CLOCK_DISPTACH
 macro
Date: Thu, 13 Jan 2011 18:03:24 +0100 (CET)
Message-ID: <alpine.LFD.2.00.1101131745400.2678@localhost6.localdomain6>
References: <cover.1294917347.git.richard.cochran@omicron.at> <90b2beef441615d01c93fcad029c44af4e505c5f.1294917348.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <90b2beef441615d01c93fcad029c44af4e505c5f.1294917348.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Jan 2011, Richard Cochran wrote:
>  int posix_cpu_clock_getres(const clockid_t which_clock, struct timespec *ts);
>  int posix_cpu_clock_get(const clockid_t which_clock, struct timespec *ts);
> -int posix_cpu_clock_set(const clockid_t which_clock, const struct timespec *ts);
> +int posix_cpu_clock_set(const clockid_t which_clock, struct timespec *ts);

Shouldn't we change the clock_set function to have *ts const in all places ?

>  static int posix_ktime_get_ts(clockid_t which_clock, struct timespec *tp)
> @@ -279,12 +230,29 @@ static __init int init_posix_timers(void)
>  {
>  	struct k_clock clock_realtime = {
>  		.clock_getres = hrtimer_get_res,
> +		/* defaults: */
> +		.clock_adj	= common_clock_adj,
> +		.clock_get	= common_clock_get,
> +		.clock_set	= common_clock_set,
> +		.nsleep		= common_nsleep,
> +		.nsleep_restart	= common_nsleep_restart,
> +		.timer_create	= common_timer_create,
> +		.timer_del	= common_timer_del,
> +		.timer_get	= common_timer_get,
> +		.timer_set	= common_timer_set,
>  	};
>  	struct k_clock clock_monotonic = {
>  		.clock_getres = hrtimer_get_res,
>  		.clock_get = posix_ktime_get_ts,
>  		.clock_set = do_posix_clock_nosettime,
>  		.clock_adj = do_posix_clock_noadjtime,
> +		/* defaults: */
> +		.nsleep		= common_nsleep,
> +		.nsleep_restart	= common_nsleep_restart,
> +		.timer_create	= common_timer_create,
> +		.timer_del	= common_timer_del,
> +		.timer_get	= common_timer_get,
> +		.timer_set	= common_timer_set,
>  	};
>  	struct k_clock clock_monotonic_raw = {
>  		.clock_getres = hrtimer_get_res,
> @@ -293,6 +261,11 @@ static __init int init_posix_timers(void)
>  		.clock_adj = do_posix_clock_noadjtime,
>  		.timer_create = no_timer_create,
>  		.nsleep = no_nsleep,
> +		/* defaults: */
> +		.nsleep_restart	= common_nsleep_restart,
> +		.timer_del	= common_timer_del,
> +		.timer_get	= common_timer_get,
> +		.timer_set	= common_timer_set,

Hmm, we do not need to set functional entries for clocks which neither
implement timer_create nor nsleep.

Otherwise I really like the outcome. :)

Thanks for your patience !

       tglx
