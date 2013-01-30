From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [RFC 3/3] arm: mach-mxs: make enabling enet_out a legacy function
Date: Wed, 30 Jan 2013 20:29:33 +0800
Message-ID: <20130130122931.GA2757@S2101-09.ap.freescale.net>
References: <1359470773-14290-1-git-send-email-w.sang@pengutronix.de>
 <1359470773-14290-4-git-send-email-w.sang@pengutronix.de>
 <20130130054833.GA24450@S2100-06.ap.freescale.net>
 <20130130075832.GA13075@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Shawn Guo <shawn.guo@freescale.com>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe001.messaging.microsoft.com ([207.46.163.24]:6351 "EHLO
	co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751124Ab3A3M3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 07:29:43 -0500
Content-Disposition: inline
In-Reply-To: <20130130075832.GA13075@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 30, 2013 at 08:58:32AM +0100, Wolfram Sang wrote:
> On Wed, Jan 30, 2013 at 01:48:40PM +0800, Shawn Guo wrote:
> > On Tue, Jan 29, 2013 at 03:46:13PM +0100, Wolfram Sang wrote:
> > > @@ -351,7 +359,7 @@ static void __init tx28_post_init(void)
> > >  	struct pinctrl *pctl;
> > >  	int ret;
> > >  
> > > -	enable_clk_enet_out();
> > > +	legacy_enable_clk_enet_out();
> > 
> > I think TX28 is the only case that really needs to turn on enet_out
> > clock at platform level, since it has some dirty work about PHY to do
> > here.  With with fec driver handling the clock, enable_clk_enet_out()
> > can just be removed for other boards.
> 
> I would love to, but this will cause regression on boards which update
> the kernel but not the devicetree (no third clock), or?
> 
Ah, that's the consideration.  When someday arch/arm/boot/dts gets
maintained outside kernel tree, we may be required to keep devicetree
compatibility to different kernel versions.  But we haven't got there
yet.  Today people are supposed to use devicetree matching kernel.

Shawn
