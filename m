From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Fri, 12 Feb 2016 18:11:13 +0100
Message-ID: <20160212171113.GC13273@lunn.ch>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EF4A2@CHN-SV-EXMX02.mchp-main.com>
 <20160211215523.GE26333@lunn.ch>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EF5AC@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Bryan.Whitehead@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45223 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752265AbcBLRLS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2016 12:11:18 -0500
Content-Disposition: inline
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264402EF5AC@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 12, 2016 at 04:51:49PM +0000, Bryan.Whitehead@microchip.com wrote:
> Hi Andrew,
> 
> Sorry I still did not make this clear. And I'm not sure I understand your question so I'll try to explain again, but please give me feedback if it's still not clear.
> 
> Also you can reference Figure 2-1 for an Internal Block Diagram on page 9 of
> http://ww1.microchip.com/downloads/en/DeviceDoc/00001923A.pdf
> 
> Conceptually I think it's easier to ignore the switch all together, since the driver really doesn't touch it.
> 
> Imagine we have two separate components
> 	1) LAN9218 (which is a 10/100 Ethernet Controller)
> 	2) An external 3 port switch (which is actually embedded)
> 
> This driver only operates on the Ethernet Controller, whose phy is in reality just a virtual phy.

> That virtual phy is connected directly to the embedded switch
> fabric, which has the two physical phys that you are asking
> about. Since this driver only operates on the Ethernet controller
> and its virtual phy. I makes no sense to talk about phy-modes for
> the physical phys on the switch.

So the code implements an MDIO bus and registers it with the MDIO
framework. It then finds the first phy and connects it to the netdev.
When doing this, it passes the phy-mode.

My assumption is, the first PHY on the MDIO bus is the PHY connected
to port 0 of the switch. So you are setting the phy-mode of this port.
This is a real phy, not a virtual phy.

     Andrew
