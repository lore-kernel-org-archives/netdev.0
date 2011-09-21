From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v2 1/3] net/fec: change phy-reset-gpio request warning to
 debug message
Date: Wed, 21 Sep 2011 20:03:42 +0800
Message-ID: <20110921120341.GG28907@S2100-06.ap.freescale.net>
References: <1316603432-20032-1-git-send-email-shawn.guo@linaro.org>
 <1316603432-20032-2-git-send-email-shawn.guo@linaro.org>
 <20110921112555.GE1966@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Shawn Guo <shawn.guo@linaro.org>,
	"David S. Miller" <davem@davemloft.net>, <patches@linaro.org>,
	<netdev@vger.kernel.org>,
	Troy Kisky <troy.kisky@boundarydevices.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	<linux-arm-kernel@lists.infradead.org>,
	Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:28794 "EHLO
	TX2EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794Ab1IULyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 07:54:05 -0400
Content-Disposition: inline
In-Reply-To: <20110921112555.GE1966@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2011 at 01:25:55PM +0200, Wolfram Sang wrote:
> Hi Shawn,
> 
> On Wed, Sep 21, 2011 at 07:10:30PM +0800, Shawn Guo wrote:
> > FEC can work without a phy reset on some platforms, which means not
> > very platform necessarily have a phy-reset gpio encoded in device tree.
> > So it makes more sense to have the phy-reset-gpio request failure as
> > a debug message rather than a warning.
> 
> Or remove it entirely?
> 
I would like to keep it.  When people want to debug at this point, they
do not need to type the debug message.

> > 
> > Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> > ---
> >  drivers/net/ethernet/freescale/fec.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
> > index 158b82e..a057abf 100644
> > --- a/drivers/net/ethernet/freescale/fec.c
> > +++ b/drivers/net/ethernet/freescale/fec.c
> > @@ -1422,7 +1422,7 @@ static int __devinit fec_reset_phy(struct platform_device *pdev)
> >  	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
> >  	err = gpio_request_one(phy_reset, GPIOF_OUT_INIT_LOW, "phy-reset");
> >  	if (err) {
> > -		pr_warn("FEC: failed to get gpio phy-reset: %d\n", err);
> > +		pr_debug("FEC: failed to get gpio phy-reset: %d\n", err);
> >  		return err;
> 
> I also wanted to suggested to drop returning the error code, since it is
> not an error anymore, strictly speaking. Then I noticed that the caller
> does not check the error code. So, this could be added or turn the
> function to void?
> 
To me, keep the return value as integer is more scalable.  Someday,
someone need to add more stuff in the function, or want to improve
the caller to check return value, it plays.

Regards,
Shawn

> >  	}
> >  	msleep(1);
> > -- 
