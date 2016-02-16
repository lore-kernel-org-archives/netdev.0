From: <Bryan.Whitehead@microchip.com>
Subject: RE: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Tue, 16 Feb 2016 19:34:26 +0000
Message-ID: <90A7E81AE28BAE4CBDDB3B35F187D264402EFAF5@CHN-SV-EXMX02.mchp-main.com>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EF4A2@CHN-SV-EXMX02.mchp-main.com>
 <20160211215523.GE26333@lunn.ch>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EF5AC@CHN-SV-EXMX02.mchp-main.com>
 <20160212171113.GC13273@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:16708 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755589AbcBPTe1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 14:34:27 -0500
In-Reply-To: <20160212171113.GC13273@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

You can find my comments below wrapped in <BW> ... </BW>

-----Original Message-----
From: Andrew Lunn [mailto:andrew@lunn.ch] 
Sent: Friday, February 12, 2016 12:11 PM
To: Bryan Whitehead - C21958
Cc: davem@davemloft.net; netdev@vger.kernel.org
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver

On Fri, Feb 12, 2016 at 04:51:49PM +0000, Bryan.Whitehead@microchip.com wrote:
> Hi Andrew,
> 
> Sorry I still did not make this clear. And I'm not sure I understand your question so I'll try to explain again, but please give me feedback if it's still not clear.
> 
> Also you can reference Figure 2-1 for an Internal Block Diagram on 
> page 9 of 
> http://ww1.microchip.com/downloads/en/DeviceDoc/00001923A.pdf
> 
> Conceptually I think it's easier to ignore the switch all together, since the driver really doesn't touch it.
> 
> Imagine we have two separate components
> 	1) LAN9218 (which is a 10/100 Ethernet Controller)
> 	2) An external 3 port switch (which is actually embedded)
> 
> This driver only operates on the Ethernet Controller, whose phy is in reality just a virtual phy.

> That virtual phy is connected directly to the embedded switch fabric, 
> which has the two physical phys that you are asking about. Since this 
> driver only operates on the Ethernet controller and its virtual phy. I 
> makes no sense to talk about phy-modes for the physical phys on the 
> switch.

So the code implements an MDIO bus and registers it with the MDIO framework. 
<BW> Yes </BW>

It then finds the first phy and connects it to the netdev.
<BW> Yes </BW>

When doing this, it passes the phy-mode.
<BW> Yes </BW>

My assumption is, the first PHY on the MDIO bus is the PHY connected to port 0 of the switch. 
<BW> Yes, that is the correct assumption </BW>

So you are setting the phy-mode of this port.
<BW> Yes </BW>

This is a real phy, not a virtual phy.
<BW> 
>From the software point of view it is a real phy, in that there is a real phy register set that can be read and written. But from the hardware point of view, it is virtual because it does not control a physical phy. 

The following is a clip from the spec.
"The Virtual PHY provides a basic MII management interface (MDIO) per EEE 802.3 (clause 22) so
that a MAC with an unmodified driver can be supported as if it was attached to a single port PHY. This
functionality is designed to allow easy and quick integration of the device into designs with minimal
driver modifications. The Virtual PHY provides a full bank of registers which comply with the IEEE
802.3 specification. This enables the Virtual PHY to provide various status and control bits similar to
those provided by a real PHY. These include the output of speed selection, duplex, loopback, isolate,
collision test, and Auto-Negotiation status."
</BW>

     Andrew
