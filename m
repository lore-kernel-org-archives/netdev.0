From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH 3/4] fec: add support for Freescale i.MX25 PDK (3DS)
Date: Tue, 15 Dec 2009 22:11:10 +0200
Message-ID: <20091215201109.GA2621@tarshish>
References: <cover.1260785451.git.baruch@tkos.co.il>
 <fb518184b206ec2727deda111cc5364134ace69a.1260785451.git.baruch@tkos.co.il>
 <20091214103348.GV15126@pengutronix.de>
 <20091215083142.GB18290@jasper.tkos.co.il>
 <4B277878.1050804@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sascha Hauer <s.hauer@pengutronix.de>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:49702 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932998AbZLOULs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2009 15:11:48 -0500
Content-Disposition: inline
In-Reply-To: <4B277878.1050804@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

On Tue, Dec 15, 2009 at 09:52:24PM +1000, Greg Ungerer wrote:
> On 12/15/2009 06:31 PM, Baruch Siach wrote:

[snip]

> >+#ifndef CONFIG_M5272
> 
> I would suggest making this conditional on FEC_MIIGSK_ENR.
> Although the CONFIG_M5272 is the only case here currently,
> that may change over the years. And using this here may not
> be obvious to the causual code reader, since the register
> offset definitions don't explicitly key on CONFIG_M5272.

OK, I'll change this conditional.

Can I take this as an Ack from you?

baruch

> 
> >+	if (fep->phy_interface == PHY_INTERFACE_MODE_RMII) {
> >+		/* disable the gasket and wait */
> >+		writel(0, fep->hwp + FEC_MIIGSK_ENR);
> >+		while (readl(fep->hwp + FEC_MIIGSK_ENR)&  4)
> >+			udelay(1);
> >+
> >+		/* configure the gasket: RMII, 50 MHz, no loopback, no echo */
> >+		writel(1, fep->hwp + FEC_MIIGSK_CFGR);
> >+
> >+		/* re-enable the gasket */
> >+		writel(2, fep->hwp + FEC_MIIGSK_ENR);
> >+	}
> >+#endif

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
