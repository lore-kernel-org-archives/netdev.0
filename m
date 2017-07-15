From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v2 1/2] dt-bindings: net: Add bindings for National
 Instruments XGE netdev
Date: Sat, 15 Jul 2017 20:37:45 +0200
Message-ID: <20170715183745.GA28217@lunn.ch>
References: <1500065326-26182-1-git-send-email-mdf@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: Moritz Fischer <mdf-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1500065326-26182-1-git-send-email-mdf-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 14, 2017 at 01:48:45PM -0700, Moritz Fischer wrote:
> This adds bindings for the NI XGE 1G/10G network device.
> 
> Signed-off-by: Moritz Fischer <mdf-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
>  Documentation/devicetree/bindings/net/nixge.txt | 32 +++++++++++++++++++++++++
>  1 file changed, 32 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/nixge.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/nixge.txt b/Documentation/devicetree/bindings/net/nixge.txt
> new file mode 100644
> index 0000000..9fff5a7
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/nixge.txt
> @@ -0,0 +1,32 @@
> +* NI XGE Ethernet controller
> +
> +Required properties:
> +- compatible: Should be "ni,xge-enet-2.00"
> +- reg: Address and length of the register set for the device
> +- interrupts: Should contain tx and rx interrupt
> +- interrupt-names: Should be "rx-irq" and "tx-irq"
> +- phy-mode: See ethernet.txt file in the same directory.

Hi Moritz

phy-handle is now required.

> +Examples (10G generic PHY):
> +	nixge0: ethernet@40000000 {
> +		compatible = "ni,xge-enet-2.00";
> +		reg = <0x40000000 0x6000>;
> +
> +		nvmem-cells = <&eth1_addr>;
> +		nvmem-cell-names = "address";
> +
> +		interrupts = <0 29 4>, <0 30 4>;

IRQ_TYPE_LEVEL_HIGH

> +		interrupt-names = "rx-irq", "tx-irq";
> +		interrupt-parent = <&intc>;
> +
> +		phy-mode = "xgmii";
> +		phy-handle = <&ethernet_phy1>;
> +
> +		ethernet_phy1: ethernet-phy@4 {
> +			compatible = "ethernet-phy-ieee802.3-c45";
> +			reg = <4>;
> +			devices = <0xa>;
> +		};

Since you don't fully implement c45, does this example actually work?
And devices is not a standard phy property.

    Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
