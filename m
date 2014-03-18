From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V5 1/8] sxgbe: Add device-tree binding support document
Date: Tue, 18 Mar 2014 11:46:56 -0700
Message-ID: <CAGVrzcbY61dtBLzYRY4xYg9CrTuMHBWCcJ+-hNLH_EvQ80xGCw@mail.gmail.com>
References: <002d01cf42d6$a3fd3a30$ebf7ae90$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, linux-samsung-soc@vger.kernel.org,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	David Miller <davem@davemloft.net>, siva.kallam@samsung.com,
	ilho215.lee@samsung.com, ks.giri@samsung.com,
	vipul.pandya@samsung.com
To: Byungho An <bh74.an@samsung.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <002d01cf42d6$a3fd3a30$ebf7ae90$@samsung.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-03-18 11:19 GMT-07:00 Byungho An <bh74.an@samsung.com>:
> From: Siva Reddy <siva.kallam@samsung.com>
>
> This patch adds binding document for SXGBE ethernet driver via device-tree.
>
> Signed-off-by: Siva Reddy Kallam <siva.kallam@samsung.com>
> Signed-off-by: Byungho An <bh74.an@samsung.com>
> ---
>  .../devicetree/bindings/net/samsung-sxgbe.txt      |   52 ++++++++++++++++++++
>  1 file changed, 52 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/samsung-sxgbe.txt
>
> diff --git a/Documentation/devicetree/bindings/net/samsung-sxgbe.txt b/Documentation/devicetree/bindings/net/samsung-sxgbe.txt
> new file mode 100644
> index 0000000..340eff6
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/samsung-sxgbe.txt
> @@ -0,0 +1,52 @@
> +* Samsung 10G Ethernet driver (SXGBE)
> +
> +Required properties:
> +- compatible: Should be "samsung,sxgbe-v2.0a"
> +- reg: Address and length of the register set for the device
> +- interrupt-parent: Should be the phandle for the interrupt controller
> +  that services interrupts for this device
> +- interrupts: Should contain the SXGBE interrupts
> +  These interrupts are ordered by fixed and follows variable
> +  trasmit DMA interrupts, receive DMA interrupts and lpi interrupt.
> +  index 0 - this is fixed common interrupt of SXGBE and it is always
> +  available.
> +  index 1 to 25 - 8 variable trasmit interrupts, variable 16 receive interrupts
> +  and 1 optional lpi interrupt.
> +- phy-mode: String, operation mode of the PHY interface.

You should reference
Documentation/devicetree/bindings/net/ethernet.txt which is more
thorough about what this is about.

> +  Supported values are: "xaui", "gmii".

xaui is not documented in
Documentation/devicetree/bindings/net/ethernet.txt, nor is it
supported in include/linux/phy.h and drivers/of/of_net.c, that should
be part of the patchset.

> +- samsung,pbl: Integer, Programmable Burst Length.
> +  Supported values are 1, 2, 4, 8, 16, or 32.
> +- samsung,burst-map: Integer, Program the possible bursts supported by sxgbe
> +  This is an interger and represents allowable DMA bursts when fixed burst.
> +  Allowable range is 0x00-0x3F. This field is valid only when fixed burst is
> +  enabled, otherwise ignored.
> +- samsung,adv-addr-mode: Boolean, Program the DMA to use Enhanced address mode.
> +- samsung,force-thresh-dma-mode: Boolean, Force DMA to use the threshold mode
> +  for both tx and rx
> +- samsung,force-sf-dma-mode: Boolean, Force DMA to use the Store and Forward
> +  mode for both tx and rx. This flag is ignored if force-thresh-dma-mode is set.
> +- samsung,phy-addr: Integer, Address of the PHY attached with SXGBE.

Please don't use a custom property for that, use a phy-handle which
points to an ePAPR compliant Ethernet PHY device tree node as
described in Documentation/devicetree/bindings/net/phy.txt.

> +
> +Optional properties:
> +- mac-address: 6 bytes, mac address

Did you intend to use 'local-mac-address'. 'mac-address' is described
by ePAPR as:

"Specifies the MAC address that was last used by the boot program.
This property should be
used in cases where the MAC address assigned to the device by the boot
program is different
from the local-mac-address property. This property shall be used only
if the value differs
from local-mac-address property value."

Does your bootloader really do something which falls into that
description? If not, use 'local-mac-address'.

> +
> +Example:
> +
> +       aliases {
> +               ethernet0 = <&sxgbe0>;
> +       };
> +
> +       sxgbe0: ethernet@1a040000 {
> +               compatible = "samsung,sxgbe-v2.0a";
> +               reg = <0 0x1a040000 0 0x10000>;
> +               interrupt-parent = <&gic>;
> +               interrupts = <0 209 4>, <0 185 4>, <0 186 4>, <0 187 4>,
> +                            <0 188 4>, <0 189 4>, <0 190 4>, <0 191 4>,
> +                            <0 192 4>, <0 193 4>, <0 194 4>, <0 195 4>,
> +                            <0 196 4>, <0 197 4>, <0 198 4>, <0 199 4>,
> +                            <0 200 4>, <0 201 4>, <0 202 4>, <0 203 4>,
> +                            <0 204 4>, <0 205 4>, <0 206 4>, <0 207 4>,
> +                            <0 208 4>, <0 210 4>;
> +               mac-address = [000000000000]; /* Filled in by U-Boot */

The preferred way to format this is:
                    mac-address = [ 00 00 00 00 00 00 ];
even better is something directly usable in case people copy/paste
this example such as 00 11 22 33 44 55.

> +               phy-mode = "xaui";

Your example is lacking a corresponding Ethernet PHY address/node.
--
Florian
