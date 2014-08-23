From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v5 1/1] net: fec: ptp: avoid register access when ipg
 clock is disabled
Date: Sat, 23 Aug 2014 21:52:34 +0200
Message-ID: <20140823195234.GA3878@localhost.localdomain>
References: <1408612178-13906-1-git-send-email-b38611@freescale.com>
 <1408612178-13906-2-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:61904 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbaHWTww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 15:52:52 -0400
Received: by mail-wi0-f178.google.com with SMTP id hi2so979535wib.11
        for <netdev@vger.kernel.org>; Sat, 23 Aug 2014 12:52:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1408612178-13906-2-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2014 at 05:09:38PM +0800, Fugang Duan wrote:
> diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
> index 82386b2..cca3617 100644
> --- a/drivers/net/ethernet/freescale/fec_ptp.c
> +++ b/drivers/net/ethernet/freescale/fec_ptp.c
> @@ -245,12 +245,20 @@ static int fec_ptp_settime(struct ptp_clock_info *ptp,
>  	u64 ns;
>  	unsigned long flags;
>  
> +	mutex_lock(&fep->ptp_clk_mutex);
> +	/* Check the ptp clock */
> +	if (!fep->ptp_clk_on) {
> +		mutex_unlock(&fep->ptp_clk_mutex);
> +		return -EINVAL;
> +	}
> +

Don't you need the same kind of check in fec_ptp_gettime, too?

>  	ns = ts->tv_sec * 1000000000ULL;
>  	ns += ts->tv_nsec;
>  
>  	spin_lock_irqsave(&fep->tmreg_lock, flags);
>  	timecounter_init(&fep->tc, &fep->cc, ns);
>  	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
> +	mutex_unlock(&fep->ptp_clk_mutex);
>  	return 0;
>  }
>  

Thanks,
Richard
