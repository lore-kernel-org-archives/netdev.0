From: Charles Keepax <ckeepax@opensource.wolfsonmicro.com>
Subject: Re: [PATCH] net: macb: Only call GPIO functions if there is a valid
 GPIO
Date: Tue, 29 Mar 2016 09:28:36 +0100
Message-ID: <20160329082836.GD31814@localhost.localdomain>
References: <1459169262-3941-1-git-send-email-ckeepax@opensource.wolfsonmicro.com>
 <56F96A23.4000001@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<patches@opensource.wolfsonmicro.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56F96A23.4000001@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 28, 2016 at 08:30:11PM +0300, Sergei Shtylyov wrote:
> >@@ -3029,7 +3030,8 @@ static int macb_remove(struct platform_device *pdev)
> >  		mdiobus_free(bp->mii_bus);
> >
> >  		/* Shutdown the PHY if there is a GPIO reset */
> >-		gpiod_set_value(bp->reset_gpio, 0);
> >+		if (bp->reset_gpio)
> >+			gpiod_set_value(bp->reset_gpio, 0);
> 
>    Hm, this function was previously OK to call with NULL (it didn't curse)...
> 

Looks like it was changed so that it does complain fairly
recently (patch librally snipped down):

commit fdeb8e1547cb9dd39d5d7223b33f3565cf86c28e
Author: Linus Walleij <linus.walleij@linaro.org>

    gpio: reflect base and ngpio into gpio_device


+#define VALIDATE_DESC_VOID(desc) do { \
+ if (!desc || !desc->gdev) { \
+         pr_warn("%s: invalid GPIO\n", __func__); \
+         return; \
+ } \
+

void gpiod_set_value(struct gpio_desc *desc, int value)
{
-   if (!desc)
-           return;
+ VALIDATE_DESC_VOID(desc);

Thanks,
Charles
