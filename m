From: Dan Carpenter <error27@gmail.com>
Subject: Re: [PATCH 2/3] tg3: Don't use IRQF_SAMPLE_RANDOM
Date: Sun, 27 Mar 2011 06:08:30 +0300
Message-ID: <20110327030830.GF1885@bicker>
References: <1301193753-10045-1-git-send-email-martinez.javier@gmail.com>
 <1301193753-10045-2-git-send-email-martinez.javier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Javier Martinez Canillas <martinez.javier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.212.179]:52261 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526Ab1C0DIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2011 23:08:53 -0400
Content-Disposition: inline
In-Reply-To: <1301193753-10045-2-git-send-email-martinez.javier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 27, 2011 at 04:42:32AM +0200, Javier Martinez Canillas wrote:
> This flag is scheduled for removal so we shouldn't used it.
> 
> Signed-off-by: Javier Martinez Canillas <martinez.javier@gmail.com>
> ---
>  drivers/net/tg3.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index c67eb19..58c6049 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -8844,12 +8844,11 @@ static int tg3_request_irq(struct tg3 *tp, int irq_num)
>  		fn = tg3_msi;
>  		if (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI)
>  			fn = tg3_msi_1shot;
> -		flags = IRQF_SAMPLE_RANDOM;

You need initialize flags to zero here.  Apparently gcc doesn't catch
this.  I'm using gcc 4.4.3-4ubuntu5.

regards,
dan carpenter
v
>  	} else {
>  		fn = tg3_interrupt;
>  		if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)
>  			fn = tg3_interrupt_tagged;
> -		flags = IRQF_SHARED | IRQF_SAMPLE_RANDOM;
> +		flags = IRQF_SHARED;
>  	}
>  
>  	return request_irq(tnapi->irq_vec, fn, flags, name, tnapi);

