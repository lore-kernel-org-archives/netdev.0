From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: off by one, try #2
Date: Wed, 11 Feb 2009 13:33:41 +0000
Message-ID: <20090211133341.GB12362@ff.dom.local>
References: <4992A214.2040300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:33698 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbZBKNds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 08:33:48 -0500
Received: by ewy14 with SMTP id 14so163192ewy.13
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2009 05:33:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4992A214.2040300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-02-2009 11:01, Roel Kluin wrote:
> Better?

Yes, but it looks like here is even more...

> 
> -------------------->8----------------8<-----------------------
> With while (x++ < n) { ... } x can reach n+1.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
>  drivers/net/3c505.c        |    4 ++--
>  drivers/net/irda/mcs7780.c |    2 +-
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
> index 6124605..fb74846 100644
> --- a/drivers/net/3c505.c
> +++ b/drivers/net/3c505.c
> @@ -500,9 +500,9 @@ static bool receive_pcb(struct net_device *dev, pcb_struct * pcb)
>  		pcb->data.raw[i++] = inb_command(dev->base_addr);
>  		if (i > MAX_PCB_DATA)
>  			INVALID_PCB_MSG(i);

i is also misused here and array can be overriden, so additional
break/return is needed.

Thanks,
Jarek P.

> -	} while ((stat & ASF_PCB_MASK) != ASF_PCB_END && j < 20000);
> +	} while ((stat & ASF_PCB_MASK) != ASF_PCB_END && j <= 20000);
>  	spin_unlock_irqrestore(&adapter->lock, flags);
> -	if (j >= 20000) {
> +	if (j > 20000) {
>  		TIMEOUT_MSG(__LINE__);
>  		return false;
>  	}
> diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
> index 7eafdca..b4f4f19 100644
> --- a/drivers/net/irda/mcs7780.c
> +++ b/drivers/net/irda/mcs7780.c
> @@ -585,7 +585,7 @@ static int mcs_speed_change(struct mcs_cb *mcs)
>  		mcs_get_reg(mcs, MCS_RESV_REG, &rval);
>  	} while(cnt++ < 100 && (rval & MCS_IRINTX));
>  
> -	if(cnt >= 100) {
> +	if(cnt > 100) {
>  		IRDA_ERROR("unable to change speed\n");
>  		ret = -EIO;
>  		goto error;
