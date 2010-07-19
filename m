From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/2] Remove REDWOOD_[456] config options and
	conditional code
Date: Mon, 19 Jul 2010 10:00:36 +1000
Message-ID: <1279497636.10390.1745.camel@pasglop>
References: <4f07b3092cafbbba37d61d367cc7484e24d18d2a.1279116162.git.qy03fugy@stud.informatik.uni-erlangen.de>
	<redwood56-reply-1-miltonm@bga.com>
	<cover.1279282865.git.qy03fugy@stud.informatik.uni-erlangen.de>
	<ca1bb25d203618c3548748f5efb6f125a96c89e0.1279282865.git.qy03fugy@stud.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>, linuxppc-dev@ozlabs.org,
	Alexander Kurz <linux@kbdbabel.org>, Paul Mackerras <paulus@samba.org>,
	John Linn <john.linn@xilinx.com>, David Brown <davidb@quicinc.com>,
	Ladislav Michl <ladis@linux-mips.org>,
	Solomon Peachy <solomon@linux-wlan.com>,
	vamos-dev@i4.informatik.uni-erlangen.de,
	Mike Frysinger <vapier@gentoo.org>, Florian Fainelli <florian@openwrt.org>,
	Artem Bityutskiy <Artem.Bityutskiy@nokia.com>,
	Nicolas Pitre <nico@fluxnic.net>, Jiri Kosina <jkosina@suse.cz>,
	linux-kernel@vger.kernel.org, Milton Miller <miltonm@bga.com>,
	netdev@vger.kernel.org, Joe Perches <joe@perches.com>,
	linux-mtd@lists.infradead.org, David Woodhouse <dwmw2@infradead.org>,
	"David S. Miller" <davem@davemloft.net>
To: Christian Dietrich <qy03fugy@stud.informatik.uni-erlangen.de>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <ca1bb25d203618c3548748f5efb6f125a96c89e0.1279282865.git.qy03fugy@stud.informatik.uni-erlangen.de>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-07-16 at 14:29 +0200, Christian Dietrich wrote:
> The config options for REDWOOD_[456] were commented out in the powerpc
> Kconfig. The ifdefs referencing this options therefore are dead and all
> references to this can be removed (Also dependencies in other KConfig
> files).
> 
> Signed-off-by: Christian Dietrich <qy03fugy@stud.informatik.uni-erlangen.de>
> Signed-off-by: Christoph Egger <siccegge@cs.fau.de>

Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

> ---
>  arch/powerpc/platforms/40x/Kconfig |   16 -------------
>  drivers/mtd/maps/Kconfig           |    2 +-
>  drivers/mtd/maps/redwood.c         |   43 ------------------------------------
>  drivers/net/Kconfig                |    2 +-
>  drivers/net/smc91x.h               |   37 -------------------------------
>  5 files changed, 2 insertions(+), 98 deletions(-)
> 
> diff --git a/arch/powerpc/platforms/40x/Kconfig b/arch/powerpc/platforms/40x/Kconfig
> index ec64264..b721764 100644
> --- a/arch/powerpc/platforms/40x/Kconfig
> +++ b/arch/powerpc/platforms/40x/Kconfig
> @@ -71,22 +71,6 @@ config MAKALU
>  	help
>  	  This option enables support for the AMCC PPC405EX board.
>  
> -#config REDWOOD_5
> -#	bool "Redwood-5"
> -#	depends on 40x
> -#	default n
> -#	select STB03xxx
> -#	help
> -#	  This option enables support for the IBM STB04 evaluation board.
> -
> -#config REDWOOD_6
> -#	bool "Redwood-6"
> -#	depends on 40x
> -#	default n
> -#	select STB03xxx
> -#	help
> -#	  This option enables support for the IBM STBx25xx evaluation board.
> -
>  #config SYCAMORE
>  #	bool "Sycamore"
>  #	depends on 40x
> diff --git a/drivers/mtd/maps/Kconfig b/drivers/mtd/maps/Kconfig
> index f22bc9f..6629d09 100644
> --- a/drivers/mtd/maps/Kconfig
> +++ b/drivers/mtd/maps/Kconfig
> @@ -321,7 +321,7 @@ config MTD_CFI_FLAGADM
>  
>  config MTD_REDWOOD
>  	tristate "CFI Flash devices mapped on IBM Redwood"
> -	depends on MTD_CFI && ( REDWOOD_4 || REDWOOD_5 || REDWOOD_6 )
> +	depends on MTD_CFI
>  	help
>  	  This enables access routines for the flash chips on the IBM
>  	  Redwood board. If you have one of these boards and would like to
> diff --git a/drivers/mtd/maps/redwood.c b/drivers/mtd/maps/redwood.c
> index 933c0b6..d2c9db0 100644
> --- a/drivers/mtd/maps/redwood.c
> +++ b/drivers/mtd/maps/redwood.c
> @@ -22,8 +22,6 @@
>  
>  #include <asm/io.h>
>  
> -#if !defined (CONFIG_REDWOOD_6)
> -
>  #define WINDOW_ADDR 0xffc00000
>  #define WINDOW_SIZE 0x00400000
>  
> @@ -69,47 +67,6 @@ static struct mtd_partition redwood_flash_partitions[] = {
>  	}
>  };
>  
> -#else /* CONFIG_REDWOOD_6 */
> -/* FIXME: the window is bigger - armin */
> -#define WINDOW_ADDR 0xff800000
> -#define WINDOW_SIZE 0x00800000
> -
> -#define RW_PART0_OF	0
> -#define RW_PART0_SZ	0x400000	/* 4 MiB data */
> -#define RW_PART1_OF	RW_PART0_OF + RW_PART0_SZ
> -#define RW_PART1_SZ	0x10000		/* 64K VPD */
> -#define RW_PART2_OF	RW_PART1_OF + RW_PART1_SZ
> -#define RW_PART2_SZ	0x400000 - (0x10000 + 0x20000)
> -#define RW_PART3_OF	RW_PART2_OF + RW_PART2_SZ
> -#define RW_PART3_SZ	0x20000
> -
> -static struct mtd_partition redwood_flash_partitions[] = {
> -	{
> -		.name = "Redwood filesystem",
> -		.offset = RW_PART0_OF,
> -		.size = RW_PART0_SZ
> -	},
> -	{
> -		.name = "Redwood OpenBIOS Vital Product Data",
> -		.offset = RW_PART1_OF,
> -		.size = RW_PART1_SZ,
> -		.mask_flags = MTD_WRITEABLE	/* force read-only */
> -	},
> -	{
> -		.name = "Redwood kernel",
> -		.offset = RW_PART2_OF,
> -		.size = RW_PART2_SZ
> -	},
> -	{
> -		.name = "Redwood OpenBIOS",
> -		.offset = RW_PART3_OF,
> -		.size = RW_PART3_SZ,
> -		.mask_flags = MTD_WRITEABLE	/* force read-only */
> -	}
> -};
> -
> -#endif /* CONFIG_REDWOOD_6 */
> -
>  struct map_info redwood_flash_map = {
>  	.name = "IBM Redwood",
>  	.size = WINDOW_SIZE,
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index ce2fcdd..313d306 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -913,7 +913,7 @@ config SMC91X
>  	tristate "SMC 91C9x/91C1xxx support"
>  	select CRC32
>  	select MII
> -	depends on ARM || REDWOOD_5 || REDWOOD_6 || M32R || SUPERH || \
> +	depends on ARM || M32R || SUPERH || \
>  		MIPS || BLACKFIN || MN10300 || COLDFIRE
>  	help
>  	  This is a driver for SMC's 91x series of Ethernet chipsets,
> diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
> index 8d2772c..ee74791 100644
> --- a/drivers/net/smc91x.h
> +++ b/drivers/net/smc91x.h
> @@ -83,43 +83,6 @@ static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
>  	}
>  }
>  
> -#elif defined(CONFIG_REDWOOD_5) || defined(CONFIG_REDWOOD_6)
> -
> -/* We can only do 16-bit reads and writes in the static memory space. */
> -#define SMC_CAN_USE_8BIT	0
> -#define SMC_CAN_USE_16BIT	1
> -#define SMC_CAN_USE_32BIT	0
> -#define SMC_NOWAIT		1
> -
> -#define SMC_IO_SHIFT		0
> -
> -#define SMC_inw(a, r)		in_be16((volatile u16 *)((a) + (r)))
> -#define SMC_outw(v, a, r)	out_be16((volatile u16 *)((a) + (r)), v)
> -#define SMC_insw(a, r, p, l) 						\
> -	do {								\
> -		unsigned long __port = (a) + (r);			\
> -		u16 *__p = (u16 *)(p);					\
> -		int __l = (l);						\
> -		insw(__port, __p, __l);					\
> -		while (__l > 0) {					\
> -			*__p = swab16(*__p);				\
> -			__p++;						\
> -			__l--;						\
> -		}							\
> -	} while (0)
> -#define SMC_outsw(a, r, p, l) 						\
> -	do {								\
> -		unsigned long __port = (a) + (r);			\
> -		u16 *__p = (u16 *)(p);					\
> -		int __l = (l);						\
> -		while (__l > 0) {					\
> -			/* Believe it or not, the swab isn't needed. */	\
> -			outw( /* swab16 */ (*__p++), __port);		\
> -			__l--;						\
> -		}							\
> -	} while (0)
> -#define SMC_IRQ_FLAGS		(0)
> -
>  #elif defined(CONFIG_SA1100_PLEB)
>  /* We can only do 16-bit reads and writes in the static memory space. */
>  #define SMC_CAN_USE_8BIT	1
