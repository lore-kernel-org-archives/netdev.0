From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] fec: Use SIMPLE_DEV_PM_OPS
Date: Tue, 16 Apr 2013 18:32:00 +0400
Message-ID: <516D60E0.6000107@cogentembedded.com>
References: <1366120731-31427-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fabio Estevam <fabio.estevam@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:53751 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935477Ab3DPOdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 10:33:08 -0400
Received: by mail-lb0-f169.google.com with SMTP id p11so625082lbi.28
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 07:33:06 -0700 (PDT)
In-Reply-To: <1366120731-31427-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 16-04-2013 17:58, Fabio Estevam wrote:

> Using SIMPLE_DEV_PM_OPS can make the code smaller and simpler.

> Also change CONFIG_PM to CONFIG_PM_SLEEP.

> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> ---
>   drivers/net/ethernet/freescale/fec_main.c |   20 +++++++-------------
>   1 file changed, 7 insertions(+), 13 deletions(-)

> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 806a56d..2e8bb58 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
[...]
> @@ -1946,23 +1946,17 @@ fec_resume(struct device *dev)
>   	return 0;
>   }
>
> -static const struct dev_pm_ops fec_pm_ops = {
> -	.suspend	= fec_suspend,
> -	.resume		= fec_resume,
> -	.freeze		= fec_suspend,
> -	.thaw		= fec_resume,
> -	.poweroff	= fec_suspend,
> -	.restore	= fec_resume,
> -};
> -#endif
> +static SIMPLE_DEV_PM_OPS(fec_pm_ops, fec_suspend, fec_resume);
> +#define FEC_PM_OPS (&fec_pm_ops)

    Nit: parens are useless here.

WBR, Sergei
