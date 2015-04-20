From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 05/11] time/posix-timers:Convert to the 64bit methods
 for k_clock callback functions
Date: Mon, 20 Apr 2015 22:48:06 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1504202243070.13914@nanos>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org> <1429509459-17068-6-git-send-email-baolin.wang@linaro.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: arnd@arndb.de, john.stultz@linaro.org, heenasirwani@gmail.com,
	pang.xunlei@linaro.org, peterz@infradead.org,
	rafael.j.wysocki@intel.com, gregkh@linuxfoundation.org,
	richardcochran@gmail.com, benh@kernel.crashing.org,
	paulus@samba.org, mpe@ellerman.id.au, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, linux390@de.ibm.com, rth@twiddle.net,
	riel@redhat.com, cl@linux.com, tj@kernel.org, fweisbec@gmail.com,
	ahh@google.com, pjt@google.com, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	y2038@lists.linaro.org
To: Baolin Wang <baolin.wang@linaro.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1429509459-17068-6-git-send-email-baolin.wang@linaro.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Apr 2015, Baolin Wang wrote:
>  /* Set clock_realtime */
>  static int posix_clock_realtime_set(const clockid_t which_clock,
> -				    const struct timespec *tp)
> +				    const struct timespec64 *tp)
>  {
> -	return do_sys_settimeofday(tp, NULL);
> +	struct timespec ts = timespec64_to_timespec(*tp);
> +
> +	return do_sys_settimeofday(&ts, NULL);

Sigh. No. We first provide a proper function for this, which takes a
timespec64, i.e. do_sys_settimeofday64() instead of having this
wrapper mess all over the place.

>  	/* SIGEV_NONE timers are not queued ! See common_timer_get */
>  	if (((timr->it_sigev_notify & ~SIGEV_THREAD_ID) == SIGEV_NONE)) {
> diff --git a/kernel/time/timekeeping.h b/kernel/time/timekeeping.h
> index 1d91416..144af14 100644
> --- a/kernel/time/timekeeping.h
> +++ b/kernel/time/timekeeping.h
> @@ -15,7 +15,7 @@ extern u64 timekeeping_max_deferment(void);
>  extern int timekeeping_inject_offset(struct timespec *ts);
>  extern s32 timekeeping_get_tai_offset(void);
>  extern void timekeeping_set_tai_offset(s32 tai_offset);
> -extern void timekeeping_clocktai(struct timespec *ts);
> +extern void timekeeping_clocktai(struct timespec64 *ts);

# git grep timekeeping_clocktai() is your friend.

Thanks,

	tglx
