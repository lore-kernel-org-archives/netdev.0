From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 09/11] cputime:Introduce the cputime_to_timespec64/timespec64_to_cputime
 function
Date: Mon, 20 Apr 2015 23:09:17 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1504202249590.13914@nanos>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org> <1429509459-17068-10-git-send-email-baolin.wang@linaro.org>
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
In-Reply-To: <1429509459-17068-10-git-send-email-baolin.wang@linaro.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Apr 2015, Baolin Wang wrote:

> This patch introduces some functions for converting cputime to timespec64 and back,
> that repalce the timespec type with timespec64 type, as well as for arch/s390 and
> arch/powerpc architecture.

No. We want a patch which adds the functions and then a patch which
uses them. This stuff is tricky and hard to review. So please split
the patches into smaller chunks.

> +unsigned long
> +timespec64_to_jiffies(const struct timespec64 *value)
> +{
> +	return __timespec_to_jiffies(value->tv_sec, value->tv_nsec);
> +}
> +EXPORT_SYMBOL(timespec64_to_jiffies);

So we have now two exports which are doing exactly the same
thing. Copy and paste is wonderful, right?

What about exporting __timespec_to_jiffies() and providing inlines for
timespec_to_jiffies() and timespec64_to_jiffies() ?

EXPORT_SYMBOL is not just a stupid annotation. Its impact on the
resulting kernel size is larger than the actual function
implementation.

> +void
> +jiffies_to_timespec64(const unsigned long jiffies, struct timespec64 *value)
> +{
> +	/*
> +	 * Convert jiffies to nanoseconds and separate with
> +	 * one divide.
> +	 */
> +	u32 rem;
> +	value->tv_sec = div_u64_rem((u64)jiffies * TICK_NSEC,
> +				   NSEC_PER_SEC, &rem);
> +	value->tv_nsec = rem;
> +}
> +EXPORT_SYMBOL(jiffies_to_timespec64);

Sigh.

Thanks,

	tglx
