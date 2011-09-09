From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v3] net/smsc911x: add device tree probe support
Date: Fri, 9 Sep 2011 19:48:57 +0800
Message-ID: <20110909114856.GA32138@S2100-06.ap.freescale.net>
References: <1311587040-8988-1-git-send-email-shawn.guo@linaro.org>
 <1312050360-15767-1-git-send-email-shawn.guo@linaro.org>
 <20110908145946.GE2070@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Shawn Guo <shawn.guo@linaro.org>, <netdev@vger.kernel.org>,
	<patches@linaro.org>, <devicetree-discuss@lists.ozlabs.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>
To: Dave Martin <dave.martin@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe004.messaging.microsoft.com ([213.199.154.142]:43624
	"EHLO DB3EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933274Ab1IILjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 07:39:53 -0400
Content-Disposition: inline
In-Reply-To: <20110908145946.GE2070@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 08, 2011 at 03:59:46PM +0100, Dave Martin wrote:
> Hi Shawn,
> 
> On Sun, Jul 31, 2011 at 02:26:00AM +0800, Shawn Guo wrote:
> > It adds device tree probe support for smsc911x driver.
> > 
> > Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> > Cc: Grant Likely <grant.likely@secretlab.ca>
> > Cc: Steve Glendinning <steve.glendinning@smsc.com>
> > Cc: David S. Miller <davem@davemloft.net>
> > Reviewed-by: Grant Likely <grant.likely@secretlab.ca>
> > ---
> > Changes since v2:
> >  * Fix a typo in smsc911x.txt
> > 
> > Changes since v1:
> >  * Instead of getting irq line from gpio number, it use irq domain
> >    to keep platform_get_resource(IORESOURCE_IRQ) works for dt too.
> >  * Use 'lan9115' the first model that smsc911x supports in the match
> >    table
> >  * Use reg-shift and reg-io-width which already used in of_serial for
> >    shift and access size binding
> 
> When using this patch with vexpress, I found that 16-bit register access
> mode doesn't seem to be getting set correctly.
> 
> Can you take a look at this additional patch and let me know if it looks
> correct?
> 
> Cheers
> ---Dave
> 
> From: Dave Martin <dave.martin@linaro.org>
> Date: Wed, 7 Sep 2011 17:26:31 +0100
> Subject: [PATCH] net/smsc911x: Correctly configure 16-bit register access from DT
> 
> The SMSC911X_USE_16BIT needs to be set when using 16-bit register
> access.  However, currently no flag is set if the DT doesn't specify
> 32-bit access.
> 
> This patch should set the SMSC911X_USE_16BIT flag in a manner consistent
> with the documented DT bindings.
> 
> Signed-off-by: Dave Martin <dave.martin@linaro.org>
> ---

Acked-by: Shawn Guo <shawn.guo@linaro.org>

>  drivers/net/smsc911x.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
> index 75c08a5..1a35c25 100644
> --- a/drivers/net/smsc911x.c
> +++ b/drivers/net/smsc911x.c
> @@ -2121,6 +2121,8 @@ static int __devinit smsc911x_probe_config_dt(
>  	of_property_read_u32(np, "reg-io-width", &width);
>  	if (width == 4)
>  		config->flags |= SMSC911X_USE_32BIT;
> +	else
> +		config->flags |= SMSC911X_USE_16BIT;
>  
>  	if (of_get_property(np, "smsc,irq-active-high", NULL))
>  		config->irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_HIGH;
> -- 
> 1.7.4.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
