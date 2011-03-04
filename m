From: Florian Fainelli <florian@openwrt.org>
Subject: mii_bus->read return checking in phy_device.c
Date: Fri, 4 Mar 2011 18:25:48 +0100
Message-ID: <201103041825.48765.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andy Fleming <afleming@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44250 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759718Ab1CDRYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 12:24:24 -0500
Received: by wyg36 with SMTP id 36so2304608wyg.19
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2011 09:24:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Andy,

While debugging a PHY probing issue with the au1000_eth, I stumbled upon this 
in drivers/net/phy/phy_device.c:

        phy_reg = bus->read(bus, addr, MII_PHYSID1);                                                  
                                   
        if (phy_reg < 0)                        
                return -EIO;

most drivers implement phylib's mdio_read callback by simply returning the 
contents of their MDIO register after a readl, ioread ... which is unsigned. 
Would not it rather make sense to check for phy_reg <= 0 instead?

This can lead for instance to believing that a PHY is present at a wrong 
address because the MDIO read function returns 0 for that particular register, 
which is logical because no PHY is present at that address.

I am asking in case I just miss something.

Thank you.
--
Florian
