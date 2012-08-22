From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: [PATCH] netdev/phy: add MDIO bus multiplexer driven by a memory-mapped
 FPGA
Date: Wed, 22 Aug 2012 15:24:05 -0700
Message-ID: <50355C05.6000407@gmail.com>
References: <1345671954-6398-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	david.daney@cavium.com
To: Timur Tabi <timur@freescale.com>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:50588 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177Ab2HVWYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 18:24:08 -0400
Received: by pbbrr13 with SMTP id rr13so136681pbb.19
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 15:24:08 -0700 (PDT)
In-Reply-To: <1345671954-6398-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2012 02:45 PM, Timur Tabi wrote:
> An FPGA controls which sub-bus is connected to the master MDIO bus.  The
> FPGA must be memory-mapped and contain only 8-bit registers (which keeps
> things simple).
>
> Tested on a Freescale P5020DS board which uses the "PIXIS" FPGA attached
> to the localbus.
>
> Signed-off-by: Timur Tabi <timur@freescale.com>
> ---
>   .../devicetree/bindings/net/mdio-mux-fpga.txt      |   74 ++++++++
>   drivers/net/phy/Kconfig                            |   13 ++
>   drivers/net/phy/Makefile                           |    1 +
>   drivers/net/phy/mdio-mux-fpga.c                    |  186 ++++++++++++++++++++

I am fine with the general concept of the patch, so I am going to start 
a Bike Shedding session with it over the names of some of the things here.

I wonder if *fpga is really a good name for this.  It is a general 
purpose multiplexer with a memory mapped control register.  I would call 
it something like mdio-mux-mmioreg.


>   4 files changed, 274 insertions(+), 0 deletions(-)
>   create mode 100644 Documentation/devicetree/bindings/net/mdio-mux-fpga.txt
>   create mode 100644 drivers/net/phy/mdio-mux-fpga.c
>
> diff --git a/Documentation/devicetree/bindings/net/mdio-mux-fpga.txt b/Documentation/devicetree/bindings/net/mdio-mux-fpga.txt
> new file mode 100644
> index 0000000..ef567c6
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/mdio-mux-fpga.txt
> @@ -0,0 +1,74 @@
> +Properties for an MDIO bus multiplexer/switch controlled by an FPGA register.
> +
> +This is a special case of a MDIO bus multiplexer.  An FPGA register is used
> +to control which child bus is connected.
> +
> +Required properties in addition to the generic multiplexer properties:
> +
> +- compatible : string, must contain "mdio-mux-fpga"
> +
> +- mdio-mux-device : phandle, points to the FPGA (or similar) node.  This
> +	must be a memory-mapped device with 8-bit registers.

You shouldn't need this.  Just make the multiplexer a child of FPGA node 
to indicate where it lives.


> +
> +- mdio-mux-register : integer, contains the offset of the register that
> +	controls the bus multiplexer.

This should just be the normal "reg" properly


> +
> +- mdio-mux-mask : integer, contains an 8-bit mask that specifies which
> +	bits in the register control the actual bus multiplexer.  The
> +	'reg' property of each child mdio-mux node must be constrained by
> +	this mask.
> +

"reg-mask" ??

Do you need a shift too?


David Daney
