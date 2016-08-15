From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH 1/9] microblaze: irqchip: Move intc driver to irqchip
Date: Mon, 15 Aug 2016 15:06:13 +0000
Message-ID: <20160815150613.GB3353@io.lakedaemon.net>
References: <1471269335-58747-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1471269335-58747-2-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: monstr@monstr.eu, ralf@linux-mips.org, tglx@linutronix.de,
	marc.zyngier@arm.com, linux-mips@linux-mips.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1471269335-58747-2-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Zubair,

On Mon, Aug 15, 2016 at 02:55:27PM +0100, Zubair Lutfullah Kakakhel wrote:
> The Xilinx AXI Interrupt Controller IP block is used by the MIPS
> based xilfpga platform.
> 
> Move the interrupt controller code out of arch/microblaze so that
> it can be used by everyone
> 
> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
> ---
>  arch/microblaze/Kconfig                                       | 1 +
>  arch/microblaze/kernel/Makefile                               | 2 +-
>  drivers/irqchip/Kconfig                                       | 4 ++++
>  drivers/irqchip/Makefile                                      | 1 +
>  arch/microblaze/kernel/intc.c => drivers/irqchip/irq-xilinx.c | 0
>  5 files changed, 7 insertions(+), 1 deletion(-)
>  rename arch/microblaze/kernel/intc.c => drivers/irqchip/irq-xilinx.c (100%)

How about irq-axi-intc.c?

> diff --git a/arch/microblaze/Kconfig b/arch/microblaze/Kconfig
> index 86f6572..198e921 100644
> --- a/arch/microblaze/Kconfig
> +++ b/arch/microblaze/Kconfig
> @@ -27,6 +27,7 @@ config MICROBLAZE
>  	select HAVE_MEMBLOCK_NODE_MAP
>  	select HAVE_OPROFILE
>  	select IRQ_DOMAIN
> +	select XILINX_IRQ
>  	select MODULES_USE_ELF_RELA
>  	select OF
>  	select OF_EARLY_FLATTREE
> diff --git a/arch/microblaze/kernel/Makefile b/arch/microblaze/kernel/Makefile
> index f08baca..e098381 100644
> --- a/arch/microblaze/kernel/Makefile
> +++ b/arch/microblaze/kernel/Makefile
> @@ -15,7 +15,7 @@ endif
>  extra-y := head.o vmlinux.lds
>  
>  obj-y += dma.o exceptions.o \
> -	hw_exception_handler.o intc.o irq.o \
> +	hw_exception_handler.o irq.o \
>  	platform.o process.o prom.o ptrace.o \
>  	reset.o setup.o signal.o sys_microblaze.o timer.o traps.o unwind.o
>  
> diff --git a/drivers/irqchip/Kconfig b/drivers/irqchip/Kconfig
> index 7f87289..b5e40ee 100644
> --- a/drivers/irqchip/Kconfig
> +++ b/drivers/irqchip/Kconfig
> @@ -203,6 +203,10 @@ config XTENSA_MX
>  	bool
>  	select IRQ_DOMAIN
>  
> +config XILINX_IRQ

XILINX_AXI_INTC ?

thx,

Jason.

> +	bool
> +	select IRQ_DOMAIN
> +
>  config IRQ_CROSSBAR
>  	bool
>  	help
> diff --git a/drivers/irqchip/Makefile b/drivers/irqchip/Makefile
> index 4c203b6..2bd833d 100644
> --- a/drivers/irqchip/Makefile
> +++ b/drivers/irqchip/Makefile
> @@ -51,6 +51,7 @@ obj-$(CONFIG_TB10X_IRQC)		+= irq-tb10x.o
>  obj-$(CONFIG_TS4800_IRQ)		+= irq-ts4800.o
>  obj-$(CONFIG_XTENSA)			+= irq-xtensa-pic.o
>  obj-$(CONFIG_XTENSA_MX)			+= irq-xtensa-mx.o
> +obj-$(CONFIG_XILINX_IRQ)		+= irq-xilinx.o
>  obj-$(CONFIG_IRQ_CROSSBAR)		+= irq-crossbar.o
>  obj-$(CONFIG_SOC_VF610)			+= irq-vf610-mscm-ir.o
>  obj-$(CONFIG_BCM6345_L1_IRQ)		+= irq-bcm6345-l1.o
> diff --git a/arch/microblaze/kernel/intc.c b/drivers/irqchip/irq-xilinx.c
> similarity index 100%
> rename from arch/microblaze/kernel/intc.c
> rename to drivers/irqchip/irq-xilinx.c
> -- 
> 1.9.1
> 
