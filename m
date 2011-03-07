From: Florian Fainelli <florian@openwrt.org>
Subject: Re: mii_bus->read return checking in phy_device.c
Date: Mon, 7 Mar 2011 10:43:56 +0100
Message-ID: <201103071043.57023.florian@openwrt.org>
References: <201103041825.48765.florian@openwrt.org> <201103041912.10252.florian@openwrt.org> <BB72AC9C-654E-43CE-9361-255767DCFC31@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "Fleming Andy-AFLEMING" <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57524 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574Ab1CGJmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 04:42:14 -0500
Received: by wyg36 with SMTP id 36so3954902wyg.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 01:42:13 -0800 (PST)
In-Reply-To: <BB72AC9C-654E-43CE-9361-255767DCFC31@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 04 March 2011 19:19:10 Fleming Andy-AFLEMING wrote:
> On Mar 4, 2011, at 12:10, "Florian Fainelli" <florian@openwrt.org> wrote:
> > On Friday 04 March 2011 19:06:20 Fleming Andy-AFLEMING wrote:
> >> On Mar 4, 2011, at 11:24, "Florian Fainelli" <florian@openwrt.org> wrote:
> >>> Hello Andy,
> >>> 
> >>> While debugging a PHY probing issue with the au1000_eth, I stumbled
> >>> upon this
> >>> 
> >>> in drivers/net/phy/phy_device.c:
> >>>       phy_reg = bus->read(bus, addr, MII_PHYSID1);
> >>>       
> >>>       if (phy_reg < 0)
> >>>       
> >>>               return -EIO;
> >>> 
> >>> most drivers implement phylib's mdio_read callback by simply returning
> >>> the contents of their MDIO register after a readl, ioread ... which is
> >>> unsigned. Would not it rather make sense to check for phy_reg <= 0
> >>> instead?
> >> 
> >> That isn't a check for a non-existent PHY.  PHY registers are unsigned
> >> 16-bit quantities.  The negative 32-bit return value would be the result
> >> of something going wrong in the bus transaction.
> > 
> > Ok, but 0 is not an acceptable value either for both ID1 and ID2.
> 
> I don't remember the exact details, but i recall we had a discussion about
> this several years ago, and decided that 0 should not be interpreted as a
> non-existent PHY. I know I have a part that has an internal PHY which
> doesnt have anything in the ID registers.  If your driver is aware that it
> did not get a response from the PHY, it should return 0xffff.  Otherwise,
> you can return 0, and just be aware that the PHY subsystem will believe
> there's a PHY there.

Allright, thanks for the clarification, I have sorted this in platform code 
registering the particular ethernet driver.
--
Florian
