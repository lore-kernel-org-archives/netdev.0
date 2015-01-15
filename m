From: Nicolas Pitre <nico@fluxnic.net>
Subject: Re: [PATCH] net: smc91x: Add Atari EtherNAT support
Date: Thu, 15 Jan 2015 11:13:41 -0500 (EST)
Message-ID: <alpine.LFD.2.11.1501151112160.1322@knanqh.ubzr>
References: <1421327175-7613-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-m68k@vger.kernel.org, Michael Schmitz <schmitzmic@gmail.com>,
	Michael Schmitz <schmitz@debian.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-reply-to: <1421327175-7613-1-git-send-email-geert@linux-m68k.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Jan 2015, Geert Uytterhoeven wrote:

> From: Michael Schmitz <schmitzmic@gmail.com>
> 
> Add Atari specific code to the smc91x Ethernet driver. This code is used
> on the EtherNAT adapter card for the Atari Falcon extension port.
> 
> Signed-off-by: Michael Schmitz <schmitz@debian.org>
> Tested-by: Christian Steigies <cts@debian.org>
> [geert: Sort Kconfig entries, split in hard and soft dependencies]
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Long gone is the time I had access to hardware with this ethernet chip, 
but FWIW:

Acked-by: Nicolas Pitre <nico@fluxnic.net>



> ---
>  drivers/net/ethernet/smsc/Kconfig  | 10 ++++++----
>  drivers/net/ethernet/smsc/smc91x.h | 21 +++++++++++++++++++++
>  2 files changed, 27 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/smsc/Kconfig b/drivers/net/ethernet/smsc/Kconfig
> index 9468e64e6007bd2e..3e97a8b43147cc7c 100644
> --- a/drivers/net/ethernet/smsc/Kconfig
> +++ b/drivers/net/ethernet/smsc/Kconfig
> @@ -5,8 +5,9 @@
>  config NET_VENDOR_SMSC
>  	bool "SMC (SMSC)/Western Digital devices"
>  	default y
> -	depends on ARM || ISA || MAC || ARM64 || MIPS || M32R || SUPERH || \
> -		BLACKFIN || MN10300 || COLDFIRE || XTENSA || NIOS2 || PCI || PCMCIA
> +	depends on ARM || ARM64 || ATARI_ETHERNAT || BLACKFIN || COLDFIRE || \
> +		   ISA || M32R || MAC || MIPS || MN10300 || NIOS2 || PCI || \
> +		   PCMCIA || SUPERH || XTENSA
>  	---help---
>  	  If you have a network (Ethernet) card belonging to this class, say Y
>  	  and read the Ethernet-HOWTO, available from
> @@ -38,8 +39,9 @@ config SMC91X
>  	tristate "SMC 91C9x/91C1xxx support"
>  	select CRC32
>  	select MII
> -	depends on (ARM || M32R || SUPERH || MIPS || BLACKFIN || \
> -		    MN10300 || COLDFIRE || ARM64 || XTENSA || NIOS2) && (!OF || GPIOLIB)
> +	depends on !OF || GPIOLIB
> +	depends on ARM || ARM64 || ATARI_ETHERNAT || BLACKFIN || COLDFIRE || \
> +		   M32R || MIPS || MN10300 || NIOS2 || SUPERH || XTENSA
>  	---help---
>  	  This is a driver for SMC's 91x series of Ethernet chipsets,
>  	  including the SMC91C94 and the SMC91C111. Say Y if you want it
> diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
> index 2a38dacbbd27fba4..be67baf5f6778d08 100644
> --- a/drivers/net/ethernet/smsc/smc91x.h
> +++ b/drivers/net/ethernet/smsc/smc91x.h
> @@ -216,6 +216,27 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
>  
>  #include <unit/smc91111.h>
>  
> +#elif defined(CONFIG_ATARI)
> +
> +#define SMC_CAN_USE_8BIT        1
> +#define SMC_CAN_USE_16BIT       1
> +#define SMC_CAN_USE_32BIT       1
> +#define SMC_NOWAIT              1
> +
> +#define SMC_inb(a, r)           readb((a) + (r))
> +#define SMC_inw(a, r)           readw((a) + (r))
> +#define SMC_inl(a, r)           readl((a) + (r))
> +#define SMC_outb(v, a, r)       writeb(v, (a) + (r))
> +#define SMC_outw(v, a, r)       writew(v, (a) + (r))
> +#define SMC_outl(v, a, r)       writel(v, (a) + (r))
> +#define SMC_insw(a, r, p, l)    readsw((a) + (r), p, l)
> +#define SMC_outsw(a, r, p, l)   writesw((a) + (r), p, l)
> +#define SMC_insl(a, r, p, l)    readsl((a) + (r), p, l)
> +#define SMC_outsl(a, r, p, l)   writesl((a) + (r), p, l)
> +
> +#define RPC_LSA_DEFAULT         RPC_LED_100_10
> +#define RPC_LSB_DEFAULT         RPC_LED_TX_RX
> +
>  #elif defined(CONFIG_ARCH_MSM)
>  
>  #define SMC_CAN_USE_8BIT	0
> -- 
> 1.9.1
> 
> 
