From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] ptp: add range check on n_samples
Date: Tue, 24 Sep 2013 14:50:50 +0200
Message-ID: <20130924125049.GA5506@netboy>
References: <20130924070557.GA28795@zhudong.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Dong Zhu <bluezhudong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130924070557.GA28795@zhudong.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 24, 2013 at 03:05:57PM +0800, Dong Zhu wrote:
> From d4eb97e8d5def76d46167c91059147e2c7d33433 Mon Sep 17 00:00:00 2001
> 
> When using PTP_SYS_OFFSET ioctl to measure the time offset between the
> PHC and system clock, we need to specify the number of measurements, the
> valid value of n_samples is between 1 to 25. If n_samples <= 0 or > 25
> it makes no sense, so this patch intends to add a range check.

The field, n_samples, is unsigned, so the check is not needed.

Thanks,
Richard
 
> Signed-off-by: Dong Zhu <bluezhudong@gmail.com>
> ---
>  drivers/ptp/ptp_chardev.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/ptp/ptp_chardev.c b/drivers/ptp/ptp_chardev.c
> index 34a0c60..4e85b23 100644
> --- a/drivers/ptp/ptp_chardev.c
> +++ b/drivers/ptp/ptp_chardev.c
> @@ -104,7 +104,8 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
>  			err = -EFAULT;
>  			break;
>  		}
> -		if (sysoff->n_samples > PTP_MAX_SAMPLES) {
> +		if (sysoff->n_samples <= 0 ||
> +		    sysoff->n_samples > PTP_MAX_SAMPLES) {
>  			err = -EINVAL;
>  			break;
>  		}
> -- 
> 1.7.11.7
> 
> -- 
> Best Regards,
> Dong Zhu
