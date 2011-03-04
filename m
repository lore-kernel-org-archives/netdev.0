From: Fleming Andy-AFLEMING <afleming@freescale.com>
Subject: Re: mii_bus->read return checking in phy_device.c
Date: Fri, 4 Mar 2011 18:19:10 +0000
Message-ID: <BB72AC9C-654E-43CE-9361-255767DCFC31@freescale.com>
References: <201103041825.48765.florian@openwrt.org>
 <1FBC63C1-A8CE-4EFA-8864-62E12C0CFCB3@freescale.com>,<201103041912.10252.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1outboundpool.messaging.microsoft.com ([216.32.181.184]:52627
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759802Ab1CDSTS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2011 13:19:18 -0500
In-Reply-To: <201103041912.10252.florian@openwrt.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mar 4, 2011, at 12:10, "Florian Fainelli" <florian@openwrt.org> wrote:

> On Friday 04 March 2011 19:06:20 Fleming Andy-AFLEMING wrote:
>> On Mar 4, 2011, at 11:24, "Florian Fainelli" <florian@openwrt.org> wrote:
>>> Hello Andy,
>>> 
>>> While debugging a PHY probing issue with the au1000_eth, I stumbled upon
>>> this
>>> 
>>> in drivers/net/phy/phy_device.c:
>>>       phy_reg = bus->read(bus, addr, MII_PHYSID1);
>>> 
>>>       if (phy_reg < 0)
>>> 
>>>               return -EIO;
>>> 
>>> most drivers implement phylib's mdio_read callback by simply returning
>>> the contents of their MDIO register after a readl, ioread ... which is
>>> unsigned. Would not it rather make sense to check for phy_reg <= 0
>>> instead?
>> 
>> That isn't a check for a non-existent PHY.  PHY registers are unsigned
>> 16-bit quantities.  The negative 32-bit return value would be the result
>> of something going wrong in the bus transaction.
> 
> Ok, but 0 is not an acceptable value either for both ID1 and ID2.


I don't remember the exact details, but i recall we had a discussion about this several years ago, and decided that 0 should not be interpreted as a non-existent PHY. I know I have a part that has an internal PHY which doesnt have anything in the ID registers.  If your driver is aware that it did not get a response from the PHY, it should return 0xffff.  Otherwise, you can return 0, and just be aware that the PHY subsystem will believe there's a PHY there.


> 
>> 
>> Notice that later the code actually checks to see if the read value was
>> mostly 1s...
> 
> What if the MDIO bus returns 0 instead of 1? Should that be fixed to return 
> 0xffff instead in the driver?
> 
>> 
>>> This can lead for instance to believing that a PHY is present at a wrong
>>> address because the MDIO read function returns 0 for that particular
>>> register, which is logical because no PHY is present at that address.
>>> 
>>> I am asking in case I just miss something.
>>> 
>>> Thank you.
>>> --
>>> Florian
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

