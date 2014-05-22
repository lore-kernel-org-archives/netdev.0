From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] micrel: Use time_before_eq()
Date: Fri, 23 May 2014 07:06:10 +0800 (SGT)
Message-ID: <alpine.DEB.2.10.1405230705350.2606@hadrien>
References: <1400781165-26498-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-849477787-1400799994=:2606"
Cc: davem@davemloft.net, jg1.han@samsung.com, dingtianhong@huawei.com,
	ebiederm@xmission.com, Julia.Lawall@lip6.fr,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: =?ISO-8859-15?Q?Manuel_Sch=F6lling?= <manuel.schoelling@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400781165-26498-1-git-send-email-manuel.schoelling@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-849477787-1400799994=:2606
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Thu, 22 May 2014, Manuel Schölling wrote:

> To be future-proof and for better readability the time comparisons are modified
> to use time_before_eq() instead of plain, error-prone math.

I had the impression that the real reason for these functions was that
they were somehow sensitive to the possibility of overflow of jiffies?

julia

> Signed-off-by: Manuel Schölling <manuel.schoelling@gmx.de>
> ---
>  drivers/net/ethernet/micrel/ksz884x.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
> index 14ac0e2..90fa5f3 100644
> --- a/drivers/net/ethernet/micrel/ksz884x.c
> +++ b/drivers/net/ethernet/micrel/ksz884x.c
> @@ -4930,7 +4930,7 @@ static void netdev_tx_timeout(struct net_device *dev)
>  		 * Only reset the hardware if time between calls is long
>  		 * enough.
>  		 */
> -		if (jiffies - last_reset <= dev->watchdog_timeo)
> +		if (time_before_eq(jiffies, last_reset + dev->watchdog_timeo))
>  			hw_priv = NULL;
>  	}
>
> --
> 1.7.10.4
>
>
--8323329-849477787-1400799994=:2606--
