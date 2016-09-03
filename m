From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 4/4] net: smsc911x: Move interrupt allocation to open/stop
Date: Sat, 3 Sep 2016 22:23:53 +0300
Message-ID: <2317c7ce-9d44-7f89-9006-ed05041a9e87@cogentembedded.com>
References: <1472760909-19688-1-git-send-email-jeremy.linton@arm.com>
 <1472760909-19688-5-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, andrew@lunn.ch, will.deacon@arm.com
To: Jeremy Linton <jeremy.linton@arm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:36392 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753239AbcICTX5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2016 15:23:57 -0400
Received: by mail-lf0-f45.google.com with SMTP id g62so103834635lfe.3
        for <netdev@vger.kernel.org>; Sat, 03 Sep 2016 12:23:56 -0700 (PDT)
In-Reply-To: <1472760909-19688-5-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2016 11:15 PM, Jeremy Linton wrote:

> The /proc/irq/xx information is incorrect for smsc911x because
> the request_irq is happening before the register_netdev has the
> proper device name. Moving it to the open also fixes the case
> of when the device is renamed.
>
> Reported-by: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
> ---
>  drivers/net/ethernet/smsc/smsc911x.c | 47 ++++++++++++++----------------------
>  1 file changed, 18 insertions(+), 29 deletions(-)
>
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index c2e56f0..4f8910b 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
[...]
> @@ -2480,38 +2491,18 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
>  	if (retval < 0)
>  		goto out_disable_resources;
>
> -	/* configure irq polarity and type before connecting isr */
> -	if (pdata->config.irq_polarity == SMSC911X_IRQ_POLARITY_ACTIVE_HIGH)
> -		intcfg |= INT_CFG_IRQ_POL_;
> -
> -	if (pdata->config.irq_type == SMSC911X_IRQ_TYPE_PUSH_PULL)
> -		intcfg |= INT_CFG_IRQ_TYPE_;
> -
> -	smsc911x_reg_write(pdata, INT_CFG, intcfg);
> -
> -	/* Ensure interrupts are globally disabled before connecting ISR */
> -	smsc911x_disable_irq_chip(dev);
> -

    Hmm, I didn't see where this code got moved to...

> -	retval = request_irq(dev->irq, smsc911x_irqhandler,
> -			     irq_flags | IRQF_SHARED, dev->name, dev);
> -	if (retval) {
> -		SMSC_WARN(pdata, probe,
> -			  "Unable to claim requested irq: %d", dev->irq);
> -		goto out_disable_resources;
> -	}
> -
>  	netif_carrier_off(dev);
>

[...]

MBR, Sergei
