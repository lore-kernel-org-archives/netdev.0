From: <Bryan.Whitehead@microchip.com>
Subject: RE: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Fri, 12 Feb 2016 16:51:49 +0000
Message-ID: <90A7E81AE28BAE4CBDDB3B35F187D264402EF5AC@CHN-SV-EXMX02.mchp-main.com>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EF4A2@CHN-SV-EXMX02.mchp-main.com>
 <20160211215523.GE26333@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:45826 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751723AbcBLQvu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 11:51:50 -0500
In-Reply-To: <20160211215523.GE26333@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Sorry I still did not make this clear. And I'm not sure I understand your question so I'll try to explain again, but please give me feedback if it's still not clear.

Also you can reference Figure 2-1 for an Internal Block Diagram on page 9 of
http://ww1.microchip.com/downloads/en/DeviceDoc/00001923A.pdf

Conceptually I think it's easier to ignore the switch all together, since the driver really doesn't touch it.

Imagine we have two separate components
	1) LAN9218 (which is a 10/100 Ethernet Controller)
	2) An external 3 port switch (which is actually embedded)

This driver only operates on the Ethernet Controller, whose phy is in reality just a virtual phy.
That virtual phy is connected directly to the embedded switch fabric, which has the two physical phys that you are asking about. Since this driver only operates on the Ethernet controller and its virtual phy. I makes no sense to talk about phy-modes for the physical phys on the switch.

If this is still not clear please let me know. If you think you understand but my explanation could be better, then please advise me on how best to explain this.

Regards,
Bryan


-----Original Message-----
From: Andrew Lunn [mailto:andrew@lunn.ch] 
Sent: Thursday, February 11, 2016 4:55 PM
To: Bryan Whitehead - C21958
Cc: davem@davemloft.net; netdev@vger.kernel.org
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver

On Thu, Feb 11, 2016 at 06:58:52PM +0000, Bryan.Whitehead@microchip.com wrote:
> This is the initial submission of an ethernet driver for the Microchip 
> LAN9352.
> 
> The LAN9352 is a 2-Port 10/100 Managed Ethernet Switch with 16-Bit 
> Non-PCI CPU Interface. The CPU interface includes a basic ethernet 
> controller interface whose virtual phy is connected internally to a 
> 3rd port on the embedded switch.
> 
> This driver only operates as a simple ethernet controller on the CPU 
> interface. Since this interface is connected directly to the embedded 
> switch, the result is that traffic can be sent and received on both 
> physical ports.
> 
> Signed-off-by: Bryan Whitehead <Bryan.Whitehead@microchip.com>
> ---
>  Documentation/devicetree/bindings/net/mchp9352.txt |   31 +
>  MAINTAINERS                                        |    9 +
>  drivers/net/ethernet/microchip/Kconfig             |   32 +-
>  drivers/net/ethernet/microchip/Makefile            |    1 +
>  drivers/net/ethernet/microchip/mchp9352.c          | 2587 ++++++++++++++++++++
>  drivers/net/ethernet/microchip/mchp9352.h          |  443 ++++
>  6 files changed, 3102 insertions(+), 1 deletion(-)  create mode 
> 100644 Documentation/devicetree/bindings/net/mchp9352.txt
>  create mode 100644 drivers/net/ethernet/microchip/mchp9352.c
>  create mode 100644 drivers/net/ethernet/microchip/mchp9352.h
> 
> diff --git a/Documentation/devicetree/bindings/net/mchp9352.txt 
> b/Documentation/devicetree/bindings/net/mchp9352.txt
> new file mode 100644
> index 0000000..5b22e73
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/mchp9352.txt
> @@ -0,0 +1,31 @@
> +* Microchip LAN9352 Controller
> +
> +Required properties:
> +- compatible : Should be "microchip,lan9352"
> +- reg : Address and length of the io space for Microchip LAN
> +- interrupts : Should contain Microchip LAN interrupt line
> +- interrupt-parent : Should be the phandle for the interrupt 
> +controller
> +  that services interrupts for this device
> +- phy-mode : See ethernet.txt file in the same directory

Hi Bryan

You still have not explained which of the two phys this phy-mode applies to? What if i want phy #0 to be rgmii and phy #1 to be rgmii-txid?

	Andrew
