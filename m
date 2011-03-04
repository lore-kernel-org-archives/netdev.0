From: Florian Fainelli <florian@openwrt.org>
Subject: Re: mii_bus->read return checking in phy_device.c
Date: Fri, 4 Mar 2011 19:12:10 +0100
Message-ID: <201103041912.10252.florian@openwrt.org>
References: <201103041825.48765.florian@openwrt.org> <1FBC63C1-A8CE-4EFA-8864-62E12C0CFCB3@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "Fleming Andy-AFLEMING" <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35598 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277Ab1CDSKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 13:10:44 -0500
Received: by wwb22 with SMTP id 22so3028627wwb.1
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2011 10:10:43 -0800 (PST)
In-Reply-To: <1FBC63C1-A8CE-4EFA-8864-62E12C0CFCB3@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 04 March 2011 19:06:20 Fleming Andy-AFLEMING wrote:
> On Mar 4, 2011, at 11:24, "Florian Fainelli" <florian@openwrt.org> wrote:
> > Hello Andy,
> > 
> > While debugging a PHY probing issue with the au1000_eth, I stumbled upon
> > this
> > 
> > in drivers/net/phy/phy_device.c:
> >        phy_reg = bus->read(bus, addr, MII_PHYSID1);
> >        
> >        if (phy_reg < 0)
> >        
> >                return -EIO;
> > 
> > most drivers implement phylib's mdio_read callback by simply returning
> > the contents of their MDIO register after a readl, ioread ... which is
> > unsigned. Would not it rather make sense to check for phy_reg <= 0
> > instead?
> 
> That isn't a check for a non-existent PHY.  PHY registers are unsigned
> 16-bit quantities.  The negative 32-bit return value would be the result
> of something going wrong in the bus transaction.

Ok, but 0 is not an acceptable value either for both ID1 and ID2.

> 
> Notice that later the code actually checks to see if the read value was
> mostly 1s...

What if the MDIO bus returns 0 instead of 1? Should that be fixed to return 
0xffff instead in the driver?

> 
> > This can lead for instance to believing that a PHY is present at a wrong
> > address because the MDIO read function returns 0 for that particular
> > register, which is logical because no PHY is present at that address.
> > 
> > I am asking in case I just miss something.
> > 
> > Thank you.
> > --
> > Florian
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
