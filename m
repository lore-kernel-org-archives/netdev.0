From: Lucas Stach <l.stach@pengutronix.de>
Subject: Re: [PATCH 1/1] Revert "net: fec: Ensure clocks are enabled while
 using mdio bus"
Date: Fri, 14 Aug 2015 11:36:34 +0200
Message-ID: <1439544994.13210.45.camel@pengutronix.de>
References: <1439531254-13128-1-git-send-email-peter.chen@freescale.com>
	 <1439540577.13210.25.camel@pengutronix.de>
	 <BN3PR0301MB08490760B426D4889AFF2434817C0@BN3PR0301MB0849.namprd03.prod.outlook.com>
	 <1439540853.13210.26.camel@pengutronix.de>
	 <20150814081444.GD11072@shlinux2>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Duan Andy <fugang.duan@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	Fabio Estevam <Fabio.Estevam@freescale.com>,
	"tyler.baker@linaro.org" <tyler.baker@linaro.org>,
	Andrew Lunn <andrew@lunn.ch>
To: Peter Chen <peter.chen@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33706 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327AbbHNJgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 05:36:38 -0400
In-Reply-To: <20150814081444.GD11072@shlinux2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, den 14.08.2015, 16:14 +0800 schrieb Peter Chen:
> On Fri, Aug 14, 2015 at 10:27:33AM +0200, Lucas Stach wrote:
> > Am Freitag, den 14.08.2015, 08:25 +0000 schrieb Peter Chen:
> > >  
> > > > 
> > > > Am Freitag, den 14.08.2015, 13:47 +0800 schrieb Peter Chen:
> > > > > It causes the i.mx6sx sdb board hang when using nfsroot during boots
> > > > > up at v4.2-rc6.
> > > > >
> > > > > This reverts commit 8fff755e9f8d0f70a595e79f248695ce6aef5cc3.
> > > > >
> > > > > Cc: netdev@vger.kernel.org
> > > > > Cc: Fugang Duan <B38611@freescale.com>
> > > > > Cc: shawn.guo@linaro.org
> > > > > Cc: fabio.estevam@freescale.com
> > > > > Cc: tyler.baker@linaro.org
> > > > > Cc: Lucas Stach <l.stach@pengutronix.de>
> > > > > Cc: Andrew Lunn <andrew@lunn.ch>
> > > > > Signed-off-by: Peter Chen <peter.chen@freescale.com>
> > > > > ---
> > > > >
> > > > > According to Fugang Duan, the i.mx series has different clock control
> > > > > sequence among SoCs, this patch may only consider certain SoCs.
> > > > >
> > > > Sorry, but NACK.
> > > > 
> > > > Please test current mainline (what will become v4.2-rc7). There is already a
> > > > patch in that fixes i.MX27 and probably fixes the same problem on i.MX6SX.
> > > > 
> > > 
> > > Would you help point to me which commit and at which tree?
> > > 
> > Mainline, so Linus Torvalds tree.
> > 
> > http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=14d2b7c1a96ef37eb571599c73d4a1a606b964d6
> 
> It fixes my imx6sx-sdb board. It is interesting that there was
> no problem for some platforms, but with problem for others.
> Your fix is a common runtime PM fix.
> 
That's because on i.MX6Q/DL IPG and AHB clock are the same clock, on
i.MX27 and apparently i.MX6SX they are different, so those chips fail if
RPM is disabling the clock at the wrong point in time.

> Again, why we need this as a bug-fix, not but as new feature for next
> rc1?

It fixes MDIO attached switches on Vybrid, but you are right this
probably could have waited until the next merge window. But this is the
wrong question to ask after we got in all the fixes to keep things from
regressing.

Seeing that people test those things pretty late (the original broken
patch got in with -rc2!) moving things to the next merge window would
just have people complaining during the v4.3 RC phase, instead of now
during the 4.2 RC phase.

Takeaway for everyone involved: test things more thoroughly and earlier.

Regards,
Lucas

-- 
Pengutronix e.K.             | Lucas Stach                 |
Industrial Linux Solutions   | http://www.pengutronix.de/  |
