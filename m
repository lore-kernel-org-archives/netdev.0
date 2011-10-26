From: Robert MARKLUND <robert.marklund@stericsson.com>
Subject: RE: [PATCH 2/2] net/smsc911x: Add regulator support
Date: Wed, 26 Oct 2011 12:57:58 +0200
Message-ID: <2B1D156D95AE9B4EAD379CB9E465FE7324AC5ED8E4@EXDCVYMBSTM005.EQ1STM.local>
References: <1319616356-6391-1-git-send-email-linus.walleij@stericsson.com>
 <20111026083838.GA9157@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirer <mathieu.poirier@linaro.org>,
	Linus Walleij <linus.walleij@linaro.org>
To: Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Linus WALLEIJ <linus.walleij@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:42964 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932673Ab1JZLIM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Oct 2011 07:08:12 -0400
In-Reply-To: <20111026083838.GA9157@opensource.wolfsonmicro.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Mark Brown [mailto:broonie@opensource.wolfsonmicro.com]
> Sent: den 26 oktober 2011 10:39
> To: Linus WALLEIJ
> Cc: netdev@vger.kernel.org; Steve Glendinning; Mathieu Poirer; Robert MARKLUND; Linus Walleij
> Subject: Re: [PATCH 2/2] net/smsc911x: Add regulator support
> 
> On Wed, Oct 26, 2011 at 10:05:56AM +0200, Linus Walleij wrote:
> 
> > +	/* enable/disable regulator for vddvario */
> > +	if (pdata->regulator_vddvario) {
> 
> This has the same issue as last time - if you've got conditional code
> like this in the body of the driver something is going wrong.  Unless
> the supply is genuinely optional and might not be physically present on
> some systems the driver should fail if it can't get it.  The regulator
> API will stub itself out when not in use.

My mistake I didn't remember to remove them.
If you review the rest of the code you see that the driver will not start if we can't get the regulators.
So that code will never run in the case where pdata->regulator_vddvario == 0.

So this will leave all the platforms using this driver and have full constraints to fail to start this driver.
If they don't create dummy regulators.

Just so we are on the clear with that.

/R
