From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH] ptp_clock: future-proofing drivers against PTP subsystem
 becoming optional
Date: Wed, 21 Sep 2016 16:10:29 +0100
Message-ID: <a93c5c69-62bd-3c5b-f2f1-e6eb721087e7@solarflare.com>
References: <alpine.LFD.2.20.1609201915070.9311@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.20.1609201915070.9311@knanqh.ubzr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21/09/16 00:25, Nicolas Pitre wrote:
> Drivers must be ready to accept NULL from ptp_clock_register() if the
> PTP clock subsystem is configured out.
>
> This patch documents that and ensures that all drivers cope well
> with a NULL return.
>
> Signed-off-by: Nicolas Pitre <nico@linaro.org>
> Reviewed-by: Eugenia Emantayev <eugenia@mellanox.com>
[...]
> diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
> index c771e0af4e..f105a170b4 100644
> --- a/drivers/net/ethernet/sfc/ptp.c
> +++ b/drivers/net/ethernet/sfc/ptp.c
> @@ -1269,13 +1269,13 @@ int efx_ptp_probe(struct efx_nic *efx, struct efx_channel *channel)
>  		if (IS_ERR(ptp->phc_clock)) {
>  			rc = PTR_ERR(ptp->phc_clock);
>  			goto fail3;
> -		}
> -
> -		INIT_WORK(&ptp->pps_work, efx_ptp_pps_worker);
> -		ptp->pps_workwq = create_singlethread_workqueue("sfc_pps");
> -		if (!ptp->pps_workwq) {
> -			rc = -ENOMEM;
> -			goto fail4;
> +		} else if (ptp->phc_clock) {
> +			INIT_WORK(&ptp->pps_work, efx_ptp_pps_worker);
> +			ptp->pps_workwq = create_singlethread_workqueue("sfc_pps");
> +			if (!ptp->pps_workwq) {
> +				rc = -ENOMEM;
> +				goto fail4;
> +			}
>  		}
>  	}
>  	ptp->nic_ts_enabled = false;
For the sfc change:
Acked-by: Edward Cree <ecree@solarflare.com>
