From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] [RFC] introduce cx82310_eth: Conexant CX82310-based
 ADSL router USB ethernet driver
Date: Wed, 08 Sep 2010 13:11:53 -0700 (PDT)
Message-ID: <20100908.131153.246543999.davem@davemloft.net>
References: <201009032317.14954.linux@rainbow-software.org>
	<4C81735E.3030903@simon.arlott.org.uk>
	<201009041439.37101.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon@fire.lp0.eu, dbrownell@users.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201009041439.37101.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ondrej Zary <linux@rainbow-software.org>
Date: Sat, 4 Sep 2010 14:39:34 +0200

> This patch introduces cx82310_eth driver - driver for USB ethernet port of 
> ADSL routers based on Conexant CX82310 chips. Such routers usually have 
> ethernet port(s) too which are bridged together with the USB ethernet port, 
> allowing the USB-connected machine to communicate to the network (and also 
> internet through the ADSL, of course).
> 
> This is my first driver, so please check thoroughly. As there's no protocol 
> documentation, it was done with usbsnoop dumps from Windows driver, some 
> parts (the commands) inspired by cxacru driver and also other usbnet drivers. 
> The driver passed my testing - some real work and also pings sized from 0 to 
> 65507 B.
> 
> The only problem I found is the ifconfig error counter. When I return 0 (or 1 
> but empty skb) from rx_fixup(), usbnet increases the error counter although 
> it's not an error condition (because packets can cross URB boundaries). Maybe 
> the usbnet should be fixed to allow rx_fixup() to return empty skbs (or some 
> other value, e.g. 2)?
> 
> The USB ID of my device is 0x0572:0xcb01 which conflicts with some ADSL modems 
> using cxacru driver (they probably use the same chipset but simpler 
> firmware). The modems seem to use bDeviceClass 0 and iProduct "ADSL USB 
> MODEM", my router uses bDeviceClass 255 and iProduct "USB NET CARD". The 
> driver matches only devices with class 255 and checks for the iProduct string 
> during init. I already posted a patch for the cxacru driver to ignore these
> devices.
>
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

Applied, thanks.
