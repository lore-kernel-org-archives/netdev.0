From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] sfc: fix return value check in efx_ptp_probe_channel()
Date: Tue, 7 May 2013 15:51:13 +0100
Message-ID: <1367938273.2782.7.camel@bwh-desktop.uk.solarflarecom.com>
References: <CAPgLHd9-6uOYFs5PVSmxGmPBidtWNWk9ZK6O8s7_6KWQihu=4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>,
	<yongjun_wei@trendmicro.com.cn>, <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17804 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300Ab3EGOvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 10:51:17 -0400
In-Reply-To: <CAPgLHd9-6uOYFs5PVSmxGmPBidtWNWk9ZK6O8s7_6KWQihu=4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-07 at 20:19 +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> In case of error, the function ptp_clock_register() returns ERR_PTR()
> and never returns NULL. The NULL test in the return value check should
> be replaced with IS_ERR().
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Although the current code is obviously wrong not to set rc, it was not
clear that ptp_clock_register() returns an ERR_PTR rather than NULL on
error.  Please could you add that fact to its kernel-doc comment?

Ben.

> ---
>  drivers/net/ethernet/sfc/ptp.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
> index 07f6baa..9a95abf 100644
> --- a/drivers/net/ethernet/sfc/ptp.c
> +++ b/drivers/net/ethernet/sfc/ptp.c
> @@ -912,8 +912,10 @@ static int efx_ptp_probe_channel(struct efx_channel *channel)
>  
>  	ptp->phc_clock = ptp_clock_register(&ptp->phc_clock_info,
>  					    &efx->pci_dev->dev);
> -	if (!ptp->phc_clock)
> +	if (IS_ERR(ptp->phc_clock)) {
> +		rc = PTR_ERR(ptp->phc_clock);
>  		goto fail3;
> +	}
>  
>  	INIT_WORK(&ptp->pps_work, efx_ptp_pps_worker);
>  	ptp->pps_workwq = create_singlethread_workqueue("sfc_pps");
> 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
