From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v2 1/3] net/fec: change phy-reset-gpio request warning to
 debug message
Date: Wed, 21 Sep 2011 20:44:24 +0800
Message-ID: <20110921124423.GI28907@S2100-06.ap.freescale.net>
References: <1316603432-20032-1-git-send-email-shawn.guo@linaro.org>
 <1316603432-20032-2-git-send-email-shawn.guo@linaro.org>
 <20110921112555.GE1966@pengutronix.de>
 <20110921120341.GG28907@S2100-06.ap.freescale.net>
 <20110921121159.GG1966@pengutronix.de>
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
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:15422 "EHLO
	TX2EHSOBE007.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529Ab1IUMfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 08:35:55 -0400
Content-Disposition: inline
In-Reply-To: <20110921121159.GG1966@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2011 at 02:11:59PM +0200, Wolfram Sang wrote:
> On Wed, Sep 21, 2011 at 08:03:42PM +0800, Shawn Guo wrote:
> > On Wed, Sep 21, 2011 at 01:25:55PM +0200, Wolfram Sang wrote:
> > > Hi Shawn,
> > > 
> > > On Wed, Sep 21, 2011 at 07:10:30PM +0800, Shawn Guo wrote:
> > > > FEC can work without a phy reset on some platforms, which means not
> > > > very platform necessarily have a phy-reset gpio encoded in device tree.
> > > > So it makes more sense to have the phy-reset-gpio request failure as
> > > > a debug message rather than a warning.
> > > 
> > > Or remove it entirely?
> > > 
> > I would like to keep it.  When people want to debug at this point, they
> > do not need to type the debug message.
> 
> I just think the message might be confusing in case you don't need the
> gpio, because then failing is expected behaviour. For those platforms,
> it is not even an error then, so you must drop returning the error. To
> be very precise, you should check of_get_named_gpio() and return if no
> gpio is specified. Then, you can distinguish that case from problems
> when getting the GPIO.
> 
The whole fec_reset_phy() should not be a show-stopper failure.  Even
on platforms that have the gpio, FEC can work without resetting the
phy in FEC driver for some cases, for example, boot loader has done it.
It might be good enough to give a warning message rather than getting
the probe fail.

> > > I also wanted to suggested to drop returning the error code, since it is
> > > not an error anymore, strictly speaking. Then I noticed that the caller
> > > does not check the error code. So, this could be added or turn the
> > > function to void?
> > > 
> > To me, keep the return value as integer is more scalable.  Someday,
> > someone need to add more stuff in the function, or want to improve
> > the caller to check return value, it plays.
> 
> I agree that keeping it int is way better. But why not add it now to
> keep things proper and tested? If this patch gets accepted as it is and
> later someone else will add error checking to the caller, your platform
> will lose FEC support as a regression.
> 
Again, fec_reset_phy() failure is not a show-stopper.  We might not
want to make the probe fail because of that.

-- 
Regards,
Shawn
