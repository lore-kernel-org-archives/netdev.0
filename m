From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] net-libertas: Better exception handling in
 if_spi_host_to_card_worker()
Date: Fri, 1 Jan 2016 22:41:28 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1601012240380.2077@localhost6.localdomain6>
References: <566ABCD9.1060404@users.sourceforge.net> <5686F0B2.5000000@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:40908 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751288AbcAAVlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jan 2016 16:41:31 -0500
In-Reply-To: <5686F0B2.5000000@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 1 Jan 2016, SF Markus Elfring wrote:

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Fri, 1 Jan 2016 22:27:20 +0100
> 
> This issue was detected by using the Coccinelle software.
> 
> Move the jump label directly before the desired log statement
> so that the variable "err" will not be checked once more
> after it was determined that a function call failed.

Putting a label inside an if is ugly.

julia

> Use the identifier "report_failure" instead of the label "err".
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  drivers/net/wireless/marvell/libertas/if_spi.c | 11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/wireless/marvell/libertas/if_spi.c b/drivers/net/wireless/marvell/libertas/if_spi.c
> index 82c0796..c9ae27e 100644
> --- a/drivers/net/wireless/marvell/libertas/if_spi.c
> +++ b/drivers/net/wireless/marvell/libertas/if_spi.c
> @@ -880,18 +880,18 @@ static void if_spi_host_to_card_worker(struct work_struct *work)
>  				&hiStatus);
>  	if (err) {
>  		netdev_err(priv->dev, "I/O error\n");
> -		goto err;
> +		goto report_failure;
>  	}
>  
>  	if (hiStatus & IF_SPI_HIST_CMD_UPLOAD_RDY) {
>  		err = if_spi_c2h_cmd(card);
>  		if (err)
> -			goto err;
> +			goto report_failure;
>  	}
>  	if (hiStatus & IF_SPI_HIST_RX_UPLOAD_RDY) {
>  		err = if_spi_c2h_data(card);
>  		if (err)
> -			goto err;
> +			goto report_failure;
>  	}
>  
>  	/*
> @@ -940,9 +940,10 @@ static void if_spi_host_to_card_worker(struct work_struct *work)
>  	if (hiStatus & IF_SPI_HIST_CARD_EVENT)
>  		if_spi_e2h(card);
>  
> -err:
> -	if (err)
> +	if (err) {
> +report_failure:
>  		netdev_err(priv->dev, "%s: got error %d\n", __func__, err);
> +	}
>  
>  	lbs_deb_leave(LBS_DEB_SPI);
>  }
> -- 
> 2.6.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
