From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH net-next v1 2/3] ARM: imx: add FEC sleep mode callback
 function
Date: Wed, 7 Jan 2015 10:33:10 +0800
Message-ID: <20150107023307.GA4928@dragon>
References: <1419413441-3406-1-git-send-email-b38611@freescale.com>
 <1419413441-3406-3-git-send-email-b38611@freescale.com>
 <20150106114807.GL24511@dragon>
 <BLUPR03MB373F1A5D01A8A6D16DC3364F5460@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:56341 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757159AbbAGCde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 21:33:34 -0500
Received: by mail-pd0-f171.google.com with SMTP id y13so1647690pdi.2
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 18:33:34 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <BLUPR03MB373F1A5D01A8A6D16DC3364F5460@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2015 at 01:41:33AM +0000, fugang.duan@freescale.com wrote:
> From: Shawn Guo <shawn.guo@linaro.org> Sent: Tuesday, January 06, 2015 7:48 PM
> > To: Duan Fugang-B38611
> > Cc: davem@davemloft.net; netdev@vger.kernel.org;
> > bhutchings@solarflare.com; stephen@networkplumber.org
> > Subject: Re: [PATCH net-next v1 2/3] ARM: imx: add FEC sleep mode
> > callback function
> > 
> > On Wed, Dec 24, 2014 at 05:30:40PM +0800, Fugang Duan wrote:
> > > i.MX6q/dl, i.MX6SX SOCs enet support sleep mode that magic packet can
> > > wake up system in suspend status. For different SOCs, there have some
> > > SOC specifical GPR register to set sleep on/off mode. So add these to
> > > callback function for driver.
> > >
> > > Signed-off-by: Fugang Duan <B38611@freescale.com>
> > 
> > I do not like this patch.  In the end, this is just a GRP register bit
> > setup per FEC driver need.  Rather than messing up platform code for each
> > SoC with the same pattern, I do not see why this can not be done by FEC
> > driver itself.
> > 
> > You can take a look at LDB driver (drivers/gpu/drm/imx/imx-ldb.c) to see
> > how this can be done.
> > 
> > Shawn
> > 
> 
> Hi, Shawn,
> 
> It is SOC related setting, not fec IP itself setting, and different SOC GPR setting is not different.
> So I think it better to put it to platform code.

The GPR difference between SoCs can be encoded in device tree as well.
It's pointless to repeat the same code pattern for every single
platform, that need to set up GPR bits for enabling magic packet wake
up, while the only difference is the register and bit offset.

The platform code will become quite messy and unmaintainable if every
device driver dump their GPR register setup code into platform.

Sorry, but it's NACK from me.

Shawn
