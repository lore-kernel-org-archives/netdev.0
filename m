From: <Bryan.Whitehead@microchip.com>
Subject: RE: [PATCH net-next] Add LAN9352 Ethernet Driver
Date: Wed, 10 Feb 2016 18:35:27 +0000
Message-ID: <90A7E81AE28BAE4CBDDB3B35F187D264402EF303@CHN-SV-EXMX02.mchp-main.com>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EF199@CHN-SV-EXMX02.mchp-main.com>
 <20160210181350.GI9492@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <corbet@lwn.net>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:48606 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753053AbcBJSf3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 13:35:29 -0500
In-Reply-To: <20160210181350.GI9492@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Thanks for your comment.

The LAN9352 actually has 2 physical ports, and one virtual port which is tied internally to the 16-bit Non-PCI CPU Interface. This driver acts as a normal Ethernet controller on the virtual port, which itself is an input to the embedded switch. The switch directs traffic as a normal switch and requires no software support. So the result is that this single ethernet driver can send and receive traffic from both physical ports. 

I will submit a revised patch to apply David's suggestion.
And I'll make sure the revised patch has a better description of how this part works.

Thanks,
Bryan

-----Original Message-----
From: Andrew Lunn [mailto:andrew@lunn.ch] 
Sent: Wednesday, February 10, 2016 1:14 PM
To: Bryan Whitehead - C21958
Cc: davem@davemloft.net; netdev@vger.kernel.org; corbet@lwn.net
Subject: Re: [PATCH net-next] Add LAN9352 Ethernet Driver

On Tue, Feb 09, 2016 at 08:40:30PM +0000, Bryan.Whitehead@microchip.com wrote:
> This is the initial submission of an ethernet driver for the Microchip 
> LAN9352.
> 
> The LAN9352 is a 2-Port 10/100 Managed Ethernet Switch with 16-Bit 
> Non-PCI CPU Interface.
> 
> While the LAN9352 is a Managed Ethernet Switch, this driver only 
> supports a simple ethernet controller interface.
> 
> Signed-off-by: Bryan Whitehead <Bryan.Whitehead@microchip.com>
> ---
>  Documentation/devicetree/bindings/net/mchp9352.txt |   31 +
>  MAINTAINERS                                        |    9 +
>  drivers/net/ethernet/microchip/Kconfig             |   23 +-
>  drivers/net/ethernet/microchip/Makefile            |    1 +
>  drivers/net/ethernet/microchip/mchp9352.c          | 2593 ++++++++++++++++++++
>  drivers/net/ethernet/microchip/mchp9352.h          |  448 ++++
>  6 files changed, 3104 insertions(+), 1 deletion(-)  create mode 
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

You say this is a 2 port switch. So which port does this phy-mode apply to? Should this be a per port property?

      Andrew
