From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Thu, 11 Feb 2016 22:55:23 +0100
Message-ID: <20160211215523.GE26333@lunn.ch>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EF4A2@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Bryan.Whitehead@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54767 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751467AbcBKVz3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2016 16:55:29 -0500
Content-Disposition: inline
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264402EF4A2@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 11, 2016 at 06:58:52PM +0000, Bryan.Whitehead@microchip.com wrote:
> This is the initial submission of an ethernet driver for
> the Microchip LAN9352.
> 
> The LAN9352 is a 2-Port 10/100 Managed Ethernet Switch with
> 16-Bit Non-PCI CPU Interface. The CPU interface includes a basic
> ethernet controller interface whose virtual phy is connected
> internally to a 3rd port on the embedded switch.
> 
> This driver only operates as a simple ethernet controller
> on the CPU interface. Since this interface is connected directly
> to the embedded switch, the result is that traffic can be sent and
> received on both physical ports.
> 
> Signed-off-by: Bryan Whitehead <Bryan.Whitehead@microchip.com>
> ---
>  Documentation/devicetree/bindings/net/mchp9352.txt |   31 +
>  MAINTAINERS                                        |    9 +
>  drivers/net/ethernet/microchip/Kconfig             |   32 +-
>  drivers/net/ethernet/microchip/Makefile            |    1 +
>  drivers/net/ethernet/microchip/mchp9352.c          | 2587 ++++++++++++++++++++
>  drivers/net/ethernet/microchip/mchp9352.h          |  443 ++++
>  6 files changed, 3102 insertions(+), 1 deletion(-)
>  create mode 100644 Documentation/devicetree/bindings/net/mchp9352.txt
>  create mode 100644 drivers/net/ethernet/microchip/mchp9352.c
>  create mode 100644 drivers/net/ethernet/microchip/mchp9352.h
> 
> diff --git a/Documentation/devicetree/bindings/net/mchp9352.txt b/Documentation/devicetree/bindings/net/mchp9352.txt
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
> +- interrupt-parent : Should be the phandle for the interrupt controller
> +  that services interrupts for this device
> +- phy-mode : See ethernet.txt file in the same directory

Hi Bryan

You still have not explained which of the two phys this phy-mode
applies to? What if i want phy #0 to be rgmii and phy #1 to be
rgmii-txid?

	Andrew
