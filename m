From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [Patch v4 06/12] MIPS: xilfpga: Use Xilinx AXI Interrupt
 Controller
Date: Fri, 2 Sep 2016 09:05:10 +0200
Message-ID: <f9420816-81f6-f5f3-8bf6-8eef7721c0c3@xilinx.com>
References: <1472748665-47774-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1472748665-47774-7-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <soren.brinkmann@xilinx.com>, <linux-kernel@vger.kernel.org>,
        <linux-mips@linux-mips.org>, <michal.simek@xilinx.com>,
        <netdev@vger.kernel.org>
To: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>,
        <monstr@monstr.eu>, <ralf@linux-mips.org>, <tglx@linutronix.de>,
        <jason@lakedaemon.net>, <marc.zyngier@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472748665-47774-7-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1.9.2016 18:50, Zubair Lutfullah Kakakhel wrote:
> IRQs from peripherals such as i2c/uart/ethernet come via
> the AXI Interrupt controller.
> 
> Select it in Kconfig for xilfpga and add the DT node
> 
> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
> 
> ---
> V3 -> V4
> No change
> 
> V2 -> V3
> No change
> 
> V1 -> V2
> Renamed select XILINX_INTC to select XILINX_AXI_INTC
> ---
>  arch/mips/Kconfig                        |  1 +
>  arch/mips/boot/dts/xilfpga/nexys4ddr.dts | 12 ++++++++++++
>  2 files changed, 13 insertions(+)
> 
> diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
> index 2638856..e8a7786 100644
> --- a/arch/mips/Kconfig
> +++ b/arch/mips/Kconfig
> @@ -426,6 +426,7 @@ config MACH_XILFPGA
>  	select SYS_SUPPORTS_ZBOOT_UART16550
>  	select USE_OF
>  	select USE_GENERIC_EARLY_PRINTK_8250
> +	select XILINX_AXI_INTC
>  	help
>  	  This enables support for the IMG University Program MIPSfpga platform.
>  
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
> +		interrupt-controller;
> +		reg = <0x10200000 0x10000>;
> +		xlnx,kind-of-intr = <0x0>;
> +		xlnx,num-intr-inputs = <0x6>;
> +
> +		interrupt-parent = <&cpuintc>;
> +		interrupts = <6>;

this is not the part of binding that's why you should remove it.
number of inputs is above that's why this is duplication.

Thanks,
Michal
