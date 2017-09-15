From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [Outreachy kernel] [PATCH] Staging: irda: Don't use assignment
 inside if statement
Date: Fri, 15 Sep 2017 21:38:47 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1709152136200.2533@hadrien>
References: <1505504036-21807-1-git-send-email-srishtishar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: samuel@sortiz.org, gregkh@linuxfoundation.org,
        netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        linux-kernel@vger.kernel.org, outreachy-kernel@googlegroups.com
To: Srishti Sharma <srishtishar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505504036-21807-1-git-send-email-srishtishar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 16 Sep 2017, Srishti Sharma wrote:

> Write assignment statement outside the if statement. Done using
> the following semantic patch by coccinelle.
>
> @@
> identifier E;
> expression F;
> statement S;
> @@
>
> -if((E = F))
> +E = F

The line above would need to end in a ;

This ends up with a lot of assignments with () around the right hand side.
Maybe you could make a series removing them afterwards.

julia

> +if(E)
>   S
>
> Signed-off-by: Srishti Sharma <srishtishar@gmail.com>
> ---
>  drivers/staging/irda/drivers/irda-usb.c | 4 ++--
>  drivers/staging/irda/drivers/mcs7780.c  | 9 ++++++---
>  drivers/staging/irda/net/irqueue.c      | 3 ++-
>  3 files changed, 10 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/staging/irda/drivers/irda-usb.c b/drivers/staging/irda/drivers/irda-usb.c
> index 723e49b..82bfc05 100644
> --- a/drivers/staging/irda/drivers/irda-usb.c
> +++ b/drivers/staging/irda/drivers/irda-usb.c
> @@ -334,9 +334,9 @@ static void irda_usb_change_speed_xbofs(struct irda_usb_cb *self)
>  	urb->transfer_flags = 0;
>
>  	/* Irq disabled -> GFP_ATOMIC */
> -	if ((ret = usb_submit_urb(urb, GFP_ATOMIC))) {
> +	ret = usb_submit_urb(urb, GFP_ATOMIC);
> +	if (ret)
>  		net_warn_ratelimited("%s(), failed Speed URB\n", __func__);
> -	}
>  }
>
>  /*------------------------------------------------------------------*/
> diff --git a/drivers/staging/irda/drivers/mcs7780.c b/drivers/staging/irda/drivers/mcs7780.c
> index c3f0b25..2b674d5 100644
> --- a/drivers/staging/irda/drivers/mcs7780.c
> +++ b/drivers/staging/irda/drivers/mcs7780.c
> @@ -605,19 +605,22 @@ static int mcs_speed_change(struct mcs_cb *mcs)
>  	if (mcs->new_speed <= 115200) {
>  		rval &= ~MCS_FIR;
>
> -		if ((rst = (mcs->speed > 115200)))
> +		rst = (mcs->speed > 115200);
> +		if (rst)
>  			mcs_set_reg(mcs, MCS_MINRXPW_REG, 0);
>
>  	} else if (mcs->new_speed <= 1152000) {
>  		rval &= ~MCS_FIR;
>
> -		if ((rst = !(mcs->speed == 576000 || mcs->speed == 1152000)))
> +		rst = !(mcs->speed == 576000 || mcs->speed == 1152000);
> +		if (rst)
>  			mcs_set_reg(mcs, MCS_MINRXPW_REG, 5);
>
>  	} else {
>  		rval |= MCS_FIR;
>
> -		if ((rst = (mcs->speed != 4000000)))
> +		rst = (mcs->speed != 4000000);
> +		if (rst)
>  			mcs_set_reg(mcs, MCS_MINRXPW_REG, 5);
>
>  	}
> diff --git a/drivers/staging/irda/net/irqueue.c b/drivers/staging/irda/net/irqueue.c
> index 160dc89..5aab072 100644
> --- a/drivers/staging/irda/net/irqueue.c
> +++ b/drivers/staging/irda/net/irqueue.c
> @@ -217,7 +217,8 @@ static __u32 hash( const char* name)
>
>  	while(*name) {
>  		h = (h<<4) + *name++;
> -		if ((g = (h & 0xf0000000)))
> +		g = (h & 0xf0000000);
> +		if (g)
>  			h ^=g>>24;
>  		h &=~g;
>  	}
> --
> 2.7.4
>
> --
> You received this message because you are subscribed to the Google Groups "outreachy-kernel" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to outreachy-kernel+unsubscribe@googlegroups.com.
> To post to this group, send email to outreachy-kernel@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/outreachy-kernel/1505504036-21807-1-git-send-email-srishtishar%40gmail.com.
> For more options, visit https://groups.google.com/d/optout.
>
