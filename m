From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH 2/2] net: fec: Improve logging
Date: Sun, 17 Feb 2013 23:08:23 +0800
Message-ID: <20130217150821.GF6782@S2101-09.ap.freescale.net>
References: <1361055207-22870-1-git-send-email-festevam@gmail.com>
 <1361055207-22870-2-git-send-email-festevam@gmail.com>
 <20130217115555.GA6782@S2101-09.ap.freescale.net>
 <CAOMZO5AT4=cYrQBG0Or7PDw18hrYYuNyg17Bt-TU2jNSg5GXWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <s.hauer@pengutronix.de>, <marex@denx.de>,
	<netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe005.messaging.microsoft.com ([213.199.154.143]:8877
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756204Ab3BQPIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2013 10:08:22 -0500
Content-Disposition: inline
In-Reply-To: <CAOMZO5AT4=cYrQBG0Or7PDw18hrYYuNyg17Bt-TU2jNSg5GXWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 17, 2013 at 10:41:11AM -0300, Fabio Estevam wrote:
> On Sun, Feb 17, 2013 at 8:55 AM, Shawn Guo <shawn.guo@linaro.org> wrote:
> 
> >> --- a/drivers/net/ethernet/freescale/fec.c
> >> +++ b/drivers/net/ethernet/freescale/fec.c
> >> @@ -1695,7 +1695,7 @@ static void fec_reset_phy(struct platform_device *pdev)
> >>       err = devm_gpio_request_one(&pdev->dev, phy_reset,
> >>                                   GPIOF_OUT_INIT_LOW, "phy-reset");
> >>       if (err) {
> >> -             pr_debug("FEC: failed to get gpio phy-reset: %d\n", err);
> >> +             dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n", err);
> >
> > Shouldn't dev_dbg be more like a equivalent of pr_debug?  The reason
> > why it's taken as a debug message rather than an error is that some
> > board design may not have reset line for phy.
> 
> If a board does not have a reset line for the PHY then it will not try
> to request the GPIO as per patch 1/2 of this series.

Argh, yes, you're right.  The pr_debug makes no sense any more with the
first patch in place, and it should become a error message.  But they
should be one patch rather than a series to make the most sense, IMO.

Shawn
