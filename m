From: walter harms <wharms@bfs.de>
Subject: Re: [patch] isdn: make sure strings are null terminated
Date: Wed, 23 Nov 2011 09:25:56 +0100
Message-ID: <4ECCAE14.3070008@bfs.de>
References: <20111123064204.GA6871@elgon.mountain>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.sz.bfs.de ([194.94.69.103]:39787 "EHLO mx01.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751698Ab1KWIgw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 03:36:52 -0500
In-Reply-To: <20111123064204.GA6871@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Am 23.11.2011 07:42, schrieb Dan Carpenter:
> These strings come from the user.  We strcpy() them inside
> cf_command() so we should check that they are NULL terminated and
> return an error if not.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/isdn/divert/divert_procfs.c b/drivers/isdn/divert/divert_procfs.c
> index 33ec9e4..0c16687 100644
> --- a/drivers/isdn/divert/divert_procfs.c
> +++ b/drivers/isdn/divert/divert_procfs.c
> @@ -242,6 +242,10 @@ static int isdn_divert_ioctl_unlocked(struct file *file, uint cmd, ulong arg)
>  		case IIOCDOCFINT:
>  			if (!divert_if.drv_to_name(dioctl.cf_ctrl.drvid))
>  				return (-EINVAL);	/* invalid driver */
> +			if (strlen(dioctl.cf_ctrl.msn) >= sizeof(dioctl.cf_ctrl.msn))
> +				return -EINVAL;
> +			if (strlen(dioctl.cf_ctrl.fwd_nr) >= sizeof(dioctl.cf_ctrl.fwd_nr))
> +				return -EINVAL;

forcing the last field to be zero seems more easy.
dioctl.cf_ctrl.fwd_nr[sizeof(dioctl.cf_ctrl.fwd_nr))-1]=0;

re,
 wh

>  			if ((i = cf_command(dioctl.cf_ctrl.drvid,
>  					    (cmd == IIOCDOCFACT) ? 1 : (cmd == IIOCDOCFDIS) ? 0 : 2,
>  					    dioctl.cf_ctrl.cfproc,
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
