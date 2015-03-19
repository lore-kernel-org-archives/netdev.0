From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 2/4] ptp/clcok:Introduce the setktime/getktime interfaces
 with "ktime_t" type
Date: Thu, 19 Mar 2015 08:54:16 +0100
Message-ID: <20150319075416.GB4568@localhost.localdomain>
References: <1426743909-24335-1-git-send-email-baolin.wang@linaro.org>
 <1426743909-24335-3-git-send-email-baolin.wang@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.stultz@linaro.com, tglx@linutronix.de, arnd@linaro.org
To: Baolin Wang <baolin.wang@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426743909-24335-3-git-send-email-baolin.wang@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 19, 2015 at 01:45:07PM +0800, Baolin Wang wrote:

> diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
> index 296b0ec..46425ad 100644
> --- a/drivers/ptp/ptp_clock.c
> +++ b/drivers/ptp/ptp_clock.c
> @@ -106,14 +106,30 @@ static int ptp_clock_getres(struct posix_clock *pc, struct timespec *tp)
>  
>  static int ptp_clock_settime(struct posix_clock *pc, const struct timespec *tp)
>  {
> +	ktime_t kt;
>  	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
> -	return ptp->info->settime(ptp->info, tp);
> +
> +	if (ptp->info->setktime) {
> +		kt = timespec_to_ktime(*tp);
> +		return ptp->info->setktime(ptp->info, kt);
> +	} else {
> +		return ptp->info->settime(ptp->info, tp);
> +	}

This conditional is just the kind of thing I *don't* want to see.  In
Documentation/ptp/ptp.txt we read:

   ** Writing clock drivers

   Clock drivers include include/linux/ptp_clock_kernel.h and register
   themselves by presenting a 'struct ptp_clock_info' to the
   registration method. Clock drivers must implement all of the
   functions in the interface. If a clock does not offer a particular
   ancillary feature, then the driver should just return -EOPNOTSUPP
   from those functions.

Please don't litter the code with tests for NULL methods everywhere.

Thanks,
Richard
