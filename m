From: "Shengzhou.Liu@freescale.com" <Shengzhou.Liu@freescale.com>
Subject: RE: [PATCH] net/phy: tune get_phy_c45_ids to support more c45 phy
Date: Mon, 13 Apr 2015 06:59:52 +0000
Message-ID: <DM2PR03MB398164CA6A138741831BAE2F8E70@DM2PR03MB398.namprd03.prod.outlook.com>
References: <1428657020-11191-1-git-send-email-Shengzhou.Liu@freescale.com>
 <20150412.204201.2242904202939074517.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0143.outbound.protection.outlook.com ([65.55.169.143]:22432
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751455AbbDMHOV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 03:14:21 -0400
In-Reply-To: <20150412.204201.2242904202939074517.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, April 13, 2015 8:42 AM
> To: Liu Shengzhou-B36685
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> f.fainelli@gmail.com
> Subject: Re: [PATCH] net/phy: tune get_phy_c45_ids to support more c45 phy
> 
> From: Shengzhou Liu <Shengzhou.Liu@freescale.com>
> Date: Fri, 10 Apr 2015 17:10:20 +0800
> 
> >  		if ((c45_ids->devices_in_package & 0x1fffffff) == 0x1fffffff) {
> > -			*phy_id = 0xffffffff;
> > -			return 0;
> > +			reg_addr = MII_ADDR_C45 | 0 << 16 | 6;
> > +			phy_reg = mdiobus_read(bus, addr, reg_addr);
> > +			if (phy_reg < 0)
> > +				return -EIO;
> 
> Why are you reading this same register again, and why are you doing it with
> the magic constant "6".  That's not '6', it's 'MDIO_DEVS2'.
> 
> The first loop executed here should have read from this address, and placed
> the value into the ->devices_in_package.
> 
> This looks really like a hack.  You're reading again the same registers, by
> hand, that the loop should already be reading properly.
> 
> Why not restructure the loop to actually probe naturally for the presence
> bits in a way that works on the chip you are trying to make work?
 
Some PHYs(e.g. Cortina CS4315/CS4340) have zero Devices In package,
If we first probe zero Devices In package by loop for(i = 0; i < num_ids && c45_ids->devices_in_package == 0; i++),
it will cause the probe fail on those C45 PHYs with non-zero Devices In package.
So we must first probe non-zero Devices In package in the loop, if the return value
of c45_ids->devices_in_package is 0x1fffffff, then try to probe zero Devices In package.
Yes, will use MDIO_DEVS1 and MDIO_DEVS2 instead of constant '6', '5' in next version.
