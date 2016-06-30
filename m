From: Ray Jui <ray.jui@broadcom.com>
Subject: Re: [RFC 6/7] dt-bindings: net: bgmac: add bindings documentation for
 bgmac
Date: Thu, 30 Jun 2016 11:06:52 -0700
Message-ID: <a6dd7282-cdd0-6e62-4666-fdb3905fe81d@broadcom.com>
References: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
 <1467142484-11161-7-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, f.fainelli@gmail.com, hauke@hauke-m.de,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jon Mason <jon.mason@broadcom.com>, zajec5@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467142484-11161-7-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jon,

On 6/28/2016 12:34 PM, Jon Mason wrote:
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> ---
>  .../devicetree/bindings/net/brcm,bgmac-enet.txt     | 21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/brcm,bgmac-enet.txt
>
> diff --git a/Documentation/devicetree/bindings/net/brcm,bgmac-enet.txt b/Documentation/devicetree/bindings/net/brcm,bgmac-enet.txt
> new file mode 100644
> index 0000000..efd36d5
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/brcm,bgmac-enet.txt
> @@ -0,0 +1,21 @@
> +Broadcom GMAC Ethernet Controller Device Tree Bindings
> +-------------------------------------------------------------
> +
> +Required properties:
> + - compatible:	"brcm,bgmac-enet"
> + - reg:		Address and length of the GMAC registers,
> +		Address and length of the GMAC IDM registers

As we know there will be additional optional register banks required for 
some of the other SoCs that the current driver has not yet supported. In 
my opinion, we should consider to make "reg-names" a mandatory property 
now and map the register blocks based on names.

I think this will help to make our life easier in the future when new 
optional SoC specific register blocks are added, such that we can map 
the register blocks based on names instead of indices, which will change 
and be different among different SoCs and will require much more complex 
logic in the driver to deal with.

> + - interrupts:	Interrupt number
> +
> +Optional properties:
> +- mac-address:	mac address to be assigned to the device
> +
> +Examples:
> +
> +gmac0: enet@18022000 {
> +	compatible = "brcm,bgmac-enet";
> +	reg = <0x18022000 0x1000>,
> +	      <0x18110000 0x1000>;
> +	interrupts = <GIC_SPI 147 IRQ_TYPE_LEVEL_HIGH>;
> +	status = "disabled";
> +};
>

Btw, I think Rob Herring should be included in the review for device 
tree binding document changes.

Thanks,

Ray
