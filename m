From: "Figo.zhang" <figo1802@gmail.com>
Subject: Re: [PATCH 2/2 v2] KS8695: fix ks8695_rx() unreasonable action.
Date: Fri, 13 Nov 2009 01:16:34 +0800
Message-ID: <1258046194.1931.18.camel@myhost>
References: <1258383490-13341-1-git-send-email-zeal>
	 <4b016886.16115e0a.355d.ffffca52@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@simtec.co.uk, davem@davemloft.net
To: zeal <zealcook@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:54405 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbZKPQEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 11:04:24 -0500
Received: by pwi3 with SMTP id 3so3339486pwi.21
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 08:04:30 -0800 (PST)
In-Reply-To: <4b016886.16115e0a.355d.ffffca52@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-11-16 at 22:58 +0800, zeal wrote:
> From: zeal <zealcook@gmail.com>
> 
> ks8695_rx() will call refill_buffers() for every incoming packet.
> Its not necessary. We just need do it after finishing receiving thing.
> And the 'RX dma engine' is in the same situation.
> This blocks our user space application. The following patch may fix it.
> 

yes, it is right.

Best,
Figo.zhang

> Signed-off-by: zeal <zealcook@gmail.com>
> ---
>  drivers/net/arm/ks8695net.c |   13 ++++++-------
>  1 files changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
> index e15451a..be256b3 100644
> --- a/drivers/net/arm/ks8695net.c
> +++ b/drivers/net/arm/ks8695net.c
> @@ -544,14 +544,13 @@ rx_finished:
>  				ksp->next_rx_desc_read =
>  					(last_rx_processed + 1) &
>  					MAX_RX_DESC_MASK;
> -
> -			/* And refill the buffers */
> -			ks8695_refill_rxbuffers(ksp);
> -
> -			/* Kick the RX DMA engine, in case it became
> -			 *  suspended */
> -			ks8695_writereg(ksp, KS8695_DRSC, 0);
>  	}
> +	/* And refill the buffers */
> +	ks8695_refill_rxbuffers(ksp);
> +
> +	/* Kick the RX DMA engine, in case it became
> +	 *  suspended */
> +	ks8695_writereg(ksp, KS8695_DRSC, 0);
>  	return received;
>  }
>  


