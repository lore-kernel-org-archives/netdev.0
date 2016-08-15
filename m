From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH 4/9] MIPS: xilfpga: Use Xilinx AXI Interrupt Controller
Date: Mon, 15 Aug 2016 15:12:59 +0000
Message-ID: <20160815151259.GC3353@io.lakedaemon.net>
References: <1471269335-58747-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1471269335-58747-5-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: monstr@monstr.eu, ralf@linux-mips.org, tglx@linutronix.de,
	marc.zyngier@arm.com, linux-mips@linux-mips.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1471269335-58747-5-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Zubair,

On Mon, Aug 15, 2016 at 02:55:30PM +0100, Zubair Lutfullah Kakakhel wrote:
> IRQs from peripherals such as i2c/uart/ethernet come via
> the AXI Interrupt controller.
> 
> Select it in Kconfig for xilfpga and add the DT node
> 
> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
> ---
>  arch/mips/Kconfig                        |  1 +
>  arch/mips/boot/dts/xilfpga/nexys4ddr.dts | 12 ++++++++++++
>  2 files changed, 13 insertions(+)
> 
> diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
> index 2638856..42ecf40 100644
> --- a/arch/mips/Kconfig
> +++ b/arch/mips/Kconfig
> @@ -426,6 +426,7 @@ config MACH_XILFPGA
>  	select SYS_SUPPORTS_ZBOOT_UART16550
>  	select USE_OF
>  	select USE_GENERIC_EARLY_PRINTK_8250
> +	select XILINX_IRQ
>  	help
>  	  This enables support for the IMG University Program MIPSfpga platform.

Please split dt changes from code changes.

> diff --git a/arch/mips/boot/dts/xilfpga/nexys4ddr.dts b/arch/mips/boot/dts/xilfpga/nexys4ddr.dts
> index 48d2112..8db660b 100644
> --- a/arch/mips/boot/dts/xilfpga/nexys4ddr.dts
> +++ b/arch/mips/boot/dts/xilfpga/nexys4ddr.dts
> @@ -17,6 +17,18 @@
>  		compatible = "mti,cpu-interrupt-controller";
>  	};
>  
> +	axi_intc: interrupt-controller@10200000 {
> +		#interrupt-cells = <1>;
> +		compatible = "xlnx,xps-intc-1.00.a";

This compatible string isn't documented, mind adding it?  Please make
sure to Cc the devicetree maintainers on it.

thx,

Jason.

> +		interrupt-controller;
> +		reg = <0x10200000 0x10000>;
> +		xlnx,kind-of-intr = <0x0>;
> +		xlnx,num-intr-inputs = <0x6>;
> +
> +		interrupt-parent = <&cpuintc>;
> +		interrupts = <6>;
> +	};
> +
>  	axi_gpio: gpio@10600000 {
>  		#gpio-cells = <1>;
>  		compatible = "xlnx,xps-gpio-1.00.a";
> -- 
> 1.9.1
> 
