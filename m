From: Fleming Andy-AFLEMING <afleming@freescale.com>
Subject: Re: mii_bus->read return checking in phy_device.c
Date: Fri, 4 Mar 2011 18:06:20 +0000
Message-ID: <1FBC63C1-A8CE-4EFA-8864-62E12C0CFCB3@freescale.com>
References: <201103041825.48765.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe005.messaging.microsoft.com ([213.199.154.143]:49651
	"EHLO DB3EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758213Ab1CDSHL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2011 13:07:11 -0500
In-Reply-To: <201103041825.48765.florian@openwrt.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mar 4, 2011, at 11:24, "Florian Fainelli" <florian@openwrt.org> wrote:

> Hello Andy,
> 
> While debugging a PHY probing issue with the au1000_eth, I stumbled upon this 
> in drivers/net/phy/phy_device.c:
> 
>        phy_reg = bus->read(bus, addr, MII_PHYSID1);                                                  
> 
>        if (phy_reg < 0)                        
>                return -EIO;
> 
> most drivers implement phylib's mdio_read callback by simply returning the 
> contents of their MDIO register after a readl, ioread ... which is unsigned. 
> Would not it rather make sense to check for phy_reg <= 0 instead?


That isn't a check for a non-existent PHY.  PHY registers are unsigned 16-bit quantities.  The negative 32-bit return value would be the result of something going wrong in the bus transaction.

Notice that later the code actually checks to see if the read value was mostly 1s...


> 
> This can lead for instance to believing that a PHY is present at a wrong 
> address because the MDIO read function returns 0 for that particular register, 
> which is logical because no PHY is present at that address.
> 
> I am asking in case I just miss something.
> 
> Thank you.
> --
> Florian
> 

