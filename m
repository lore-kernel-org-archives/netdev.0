From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH 8/9] MIPS: xilfpga: Add DT node for AXI emaclite
Date: Mon, 15 Aug 2016 15:17:03 +0000
Message-ID: <20160815151703.GD3353@io.lakedaemon.net>
References: <1471269335-58747-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1471269335-58747-9-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: monstr@monstr.eu, ralf@linux-mips.org, tglx@linutronix.de,
	marc.zyngier@arm.com, linux-mips@linux-mips.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pmta2.delivery5.ore.mailhop.org ([54.186.218.12]:47240 "EHLO
	pmta2.delivery5.ore.mailhop.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932184AbcHOPRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 11:17:08 -0400
Content-Disposition: inline
In-Reply-To: <1471269335-58747-9-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Zubair,

On Mon, Aug 15, 2016 at 02:55:34PM +0100, Zubair Lutfullah Kakakhel wrote:
> The xilfpga platform has a Xilinx AXI emaclite block.
> 
> Add the DT node to use it.
> 
> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
> ---
>  arch/mips/boot/dts/xilfpga/nexys4ddr.dts | 27 +++++++++++++++++++++++++++
>  1 file changed, 27 insertions(+)
> 
> diff --git a/arch/mips/boot/dts/xilfpga/nexys4ddr.dts b/arch/mips/boot/dts/xilfpga/nexys4ddr.dts
> index 3658e21..58bc62f 100644
> --- a/arch/mips/boot/dts/xilfpga/nexys4ddr.dts
> +++ b/arch/mips/boot/dts/xilfpga/nexys4ddr.dts
> @@ -42,6 +42,33 @@
>  		xlnx,tri-default = <0xffffffff>;
>  	} ;
>  
> +	axi_ethernetlite: ethernet@10e00000 {
> +		compatible = "xlnx,xps-ethernetlite-3.00.a";

This one also isn't documented.

> +		device_type = "network";
> +		interrupt-parent = <&axi_intc>;
> +		interrupts = <1>;
> +		local-mac-address = [08 86 4C 0D F7 09];

I'm pretty sure you don't want this in the mainline dts file.

thx,

Jason.

> +		phy-handle = <&phy0>;
> +		reg = <0x10e00000 0x10000>;
> +		xlnx,duplex = <0x1>;
> +		xlnx,include-global-buffers = <0x1>;
> +		xlnx,include-internal-loopback = <0x0>;
> +		xlnx,include-mdio = <0x1>;
> +		xlnx,instance = "axi_ethernetlite_inst";
> +		xlnx,rx-ping-pong = <0x1>;
> +		xlnx,s-axi-id-width = <0x1>;
> +		xlnx,tx-ping-pong = <0x1>;
> +		xlnx,use-internal = <0x0>;
> +		mdio {
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +			phy0: phy@1 {
> +				device_type = "ethernet-phy";
> +				reg = <1>;
> +			};
> +		};
> +	};
> +
>  	axi_uart16550: serial@10400000 {
>  		compatible = "ns16550a";
>  		reg = <0x10400000 0x10000>;
> -- 
> 1.9.1
> 
