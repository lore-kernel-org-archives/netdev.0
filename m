From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC net-next 22/22] ptp: remove 32 bit get/set methods.
Date: Sat, 21 Mar 2015 22:19:24 +0100
Message-ID: <20150321211924.GA6322@localhost.localdomain>
References: <cover.1426970294.git.richardcochran@gmail.com>
 <f7bea007b66111ed84d335bd608ec6ac9834f905.1426970294.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Arnd Bergmann <arnd@linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Chris Metcalf <cmetcalf@ezchip.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f7bea007b66111ed84d335bd608ec6ac9834f905.1426970294.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 21, 2015 at 09:59:52PM +0100, Richard Cochran wrote:

> diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
> index 296b0ec..2665360 100644
> --- a/drivers/ptp/ptp_clock.c
> +++ b/drivers/ptp/ptp_clock.c
> @@ -107,13 +107,21 @@ static int ptp_clock_getres(struct posix_clock *pc, struct timespec *tp)
>  static int ptp_clock_settime(struct posix_clock *pc, const struct timespec *tp)
>  {
>  	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
> -	return ptp->info->settime(ptp->info, tp);
> +	struct timespec64 ts = timespec_to_timespec64(*tp);
> +
> +	return ptp->info->settime64(ptp->info, &ts);
>  }
>  
>  static int ptp_clock_gettime(struct posix_clock *pc, struct timespec *tp)
>  {
>  	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
> -	return ptp->info->gettime(ptp->info, tp);
> +	struct timespec64 ts;
> +	int err;
> +
> +	err = ptp->info->gettime64(ptp->info, &ts);
> +	if (!err)
> +		*tp = timespec64_to_timespec(ts);
> +	return err;
>  }

Oops, both of these functions should have started using the new
methods *before* migrating the drivers.  Will fix in V2.

Thanks,
Richard
