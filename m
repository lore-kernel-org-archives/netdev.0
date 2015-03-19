From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/4] ptp/chardev:Introduce another option to get/set time
 in ptp_clock_info structure
Date: Thu, 19 Mar 2015 08:48:16 +0100
Message-ID: <20150319074816.GA4568@localhost.localdomain>
References: <1426743909-24335-1-git-send-email-baolin.wang@linaro.org>
 <1426743909-24335-2-git-send-email-baolin.wang@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.stultz@linaro.com, tglx@linutronix.de, arnd@linaro.org
To: Baolin Wang <baolin.wang@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426743909-24335-2-git-send-email-baolin.wang@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 19, 2015 at 01:45:06PM +0800, Baolin Wang wrote:

> diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
> index 0d8ff3f..86decc2 100644
> --- a/include/linux/ptp_clock_kernel.h
> +++ b/include/linux/ptp_clock_kernel.h
> @@ -105,7 +105,9 @@ struct ptp_clock_info {
>  	int (*adjfreq)(struct ptp_clock_info *ptp, s32 delta);
>  	int (*adjtime)(struct ptp_clock_info *ptp, s64 delta);
>  	int (*gettime)(struct ptp_clock_info *ptp, struct timespec *ts);
> +	int (*getktime)(struct ptp_clock_info *ptp, ktime_t *kt);
>  	int (*settime)(struct ptp_clock_info *ptp, const struct timespec *ts);
> +	int (*setktime)(struct ptp_clock_info *ptp, ktime_t kt);

You have added alternate methods that do exactly the same thing as
gettime/settime.  Then, you convert just two drivers over to the new
interface.

I don't want to have this job half done, with some driver being
forgotten along the way.  Please, just change the signatures of
gettime/settime and convert *all* of the drivers.  After all, there
are not that many drivers to convert.

Thanks,
Richard

>  	int (*enable)(struct ptp_clock_info *ptp,
>  		      struct ptp_clock_request *request, int on);
>  	int (*verify)(struct ptp_clock_info *ptp, unsigned int pin,
> -- 
> 1.7.9.5
> 
