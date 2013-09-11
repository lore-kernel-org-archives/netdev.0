From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH] net: fec: fix phy reset operation to let imx6sl evk work
Date: Wed, 11 Sep 2013 01:17:19 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE016ACCFC@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1378804053-5094-1-git-send-email-B38611@freescale.com>
 <20130910184856.GF30088@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Li Frank-B20596 <B20596@freescale.com>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.199.154.184] ([213.199.154.184]:37449 "EHLO
	db8outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752448Ab3IKBSz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 21:18:55 -0400
In-Reply-To: <20130910184856.GF30088@pengutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hauer [mailto:s.hauer@pengutronix.de]
Data: Wednesday, September 11, 2013 2:49 AM

> To: Duan Fugang-B38611
> Cc: shawn.guo@linaro.org; davem@davemloft.net; netdev@vger.kernel.org;
> bhutchings@solarflare.com; stephen@networkplumber.org; Li Frank-B20596
> Subject: Re: [PATCH] net: fec: fix phy reset operation to let imx6sl evk
> work
> 
> On Tue, Sep 10, 2013 at 05:07:33PM +0800, Fugang Duan wrote:
> > diff --git a/drivers/net/ethernet/freescale/fec_main.c
> > b/drivers/net/ethernet/freescale/fec_main.c
> > index f9aacf5..0c17df2 100644
> > --- a/drivers/net/ethernet/freescale/fec_main.c
> > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > @@ -61,6 +61,7 @@
> >  #include "fec.h"
> >
> >  static void set_multicast_list(struct net_device *ndev);
> > +static void fec_enet_reset_phy(struct platform_device *pdev);
> 
> Please move the function up and remove the prototype.
Ok, i will do it. Thanks.

> 
> > @@ -1780,6 +1781,10 @@ fec_enet_open(struct net_device *ndev)
> >  	phy_start(fep->phy_dev);
> >  	netif_start_queue(ndev);
> >  	fep->opened = 1;
> > +
> > +	/* reset phy */
> > +	fec_enet_reset_phy(fep->pdev);
> 
> Drop this comment. It's very redundant to the function name.
Thanks, I will remove the comment.

> 
> > +static void fec_enet_reset_phy(struct platform_device *pdev)
> >  {
> > -	/*
> > -	 * In case of platform probe, the reset has been done
> > -	 * by machine code.
> > -	 */
> > +	struct net_device *ndev = platform_get_drvdata(pdev);
> > +	struct fec_enet_private *fep = netdev_priv(ndev);
> > +
> > +	/* check GPIO valid to avoid kernel print warning when no gpio reset
> */
> > +	if (gpio_is_valid(fep->phy_reset_gpio)) {
> > +		gpio_set_value(fep->phy_reset_gpio, 0);
> > +		msleep(fep->reset_duration);
> > +		gpio_set_value(fep->phy_reset_gpio, 1);
> > +	}
> 
> Drop the comment. It's obvious why it's a good idea to check for a valid
> gpio.

Thanks, I will remove the comments.
