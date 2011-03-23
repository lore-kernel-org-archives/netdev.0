From: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V12 4/4] ptp: Added a clock driver for the National
 Semiconductor PHYTER.
Date: Wed, 23 Mar 2011 14:46:25 -0700
Message-ID: <1300916785.848.54.camel@work-vm>
References: <cover.1298878618.git.richard.cochran@omicron.at>
	 <f8af215ebe32a8c0f4b3a82b8ee7e8008b4feb1e.1298878618.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <f8af215ebe32a8c0f4b3a82b8ee7e8008b4feb1e.1298878618.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-02-28 at 08:58 +0100, Richard Cochran wrote:
> This patch adds support for the PTP clock found on the DP83640.
> The basic clock operations and one external time stamp have
> been implemented.

Just locking rule comment nits here.

> +static int tdr_write(int bc, struct phy_device *dev,
> +		     const struct timespec *ts, u16 cmd)
> +{
> +	ext_write(bc, dev, PAGE4, PTP_TDR, ts->tv_nsec & 0xffff);/* ns[15:0]  */
> +	ext_write(bc, dev, PAGE4, PTP_TDR, ts->tv_nsec >> 16);   /* ns[31:16] */
> +	ext_write(bc, dev, PAGE4, PTP_TDR, ts->tv_sec & 0xffff); /* sec[15:0] */
> +	ext_write(bc, dev, PAGE4, PTP_TDR, ts->tv_sec >> 16);    /* sec[31:16]*/
> +
> +	ext_write(bc, dev, PAGE4, PTP_CTL, cmd);
> +
> +	return 0;
> +}

The above needs to hold the extreg_lock, and should be commented as
such.

And again, the function names are sort of generic, and could use a
dp83640_ prefix or something.

thanks
-john
