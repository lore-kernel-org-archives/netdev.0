From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 1/1] Added additional callback to ptp_clock_info:
Date: Fri, 3 Jul 2015 09:00:40 +0200
Message-ID: <20150703070040.GB1751@localhost.localdomain>
References: <1435886088-13890-1-git-send-email-christopher.s.hall@intel.com>
 <1435886088-13890-2-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, john.stultz@linaro.org, tglx@linutronix.de
To: Christopher Hall <christopher.s.hall@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:38879 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754681AbbGCHAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 03:00:45 -0400
Content-Disposition: inline
In-Reply-To: <1435886088-13890-2-git-send-email-christopher.s.hall@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have three nits to pick...

On Thu, Jul 02, 2015 at 06:14:48PM -0700, Christopher Hall wrote:
> diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
> index b8b7306..344f129 100644
> --- a/include/linux/ptp_clock_kernel.h
> +++ b/include/linux/ptp_clock_kernel.h
> @@ -67,6 +67,11 @@ struct ptp_clock_request {
>   * @gettime64:  Reads the current time from the hardware clock.
>   *              parameter ts: Holds the result.
>   *
> + * @getsynctime64:  Reads the current time from the hardware clock and system
> + *                  clock simultaneously.
> + *                  parameter dev: Holds the device time
> + *                  parameter sys: Holds the system time
> + *
>   * @settime64:  Set the current time on the hardware clock.
>   *              parameter ts: Time value to set.
>   *
> @@ -105,6 +110,9 @@ struct ptp_clock_info {
>  	int (*adjfreq)(struct ptp_clock_info *ptp, s32 delta);
>  	int (*adjtime)(struct ptp_clock_info *ptp, s64 delta);
>  	int (*gettime64)(struct ptp_clock_info *ptp, struct timespec64 *ts);
> +	int (*getsynctime64)
> +		(struct ptp_clock_info *ptp, struct timespec64 *dev,
> +		 struct timespec64 *sys);

This indentation looks funny, how about:

	int (*getsynctime64)(struct ptp_clock_info *ptp, struct timespec64 *dev,
			     struct timespec64 *sys);

>  	int (*settime64)(struct ptp_clock_info *p, const struct timespec64 *ts);
>  	int (*enable)(struct ptp_clock_info *ptp,
>  		      struct ptp_clock_request *request, int on);
> diff --git a/include/uapi/linux/ptp_clock.h b/include/uapi/linux/ptp_clock.h
> index f0b7bfe..421b637 100644
> --- a/include/uapi/linux/ptp_clock.h
> +++ b/include/uapi/linux/ptp_clock.h
> @@ -51,7 +51,9 @@ struct ptp_clock_caps {
>  	int n_per_out; /* Number of programmable periodic signals. */
>  	int pps;       /* Whether the clock supports a PPS callback. */
>  	int n_pins;    /* Number of input/output pins. */
> -	int rsv[14];   /* Reserved for future use. */
> +	/* Whether the clock supports precise system-device cross timestamps */
> +	int precise_timestamping;

I prefer another name, like "cross_timestamping" or similar.  I get
lots and lots of nube questions about PTP, and people will start
asking whether this means their packet time stamps are bad.

Also, could you update Documentation/ptp/testptp.c with the new field?

Thanks,
Richard
