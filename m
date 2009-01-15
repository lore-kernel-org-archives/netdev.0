From: "stanley.miao" <stanley.miao@windriver.com>
Subject: Re: [PATCH 5/5] arm: convert omap ldp platform to use smsc911x
Date: Thu, 15 Jan 2009 17:23:51 +0800
Message-ID: <1232011431.6810.34.camel@localhost>
References: <1232010482-3744-1-git-send-email-steve.glendinning@smsc.com>
	 <1232010482-3744-2-git-send-email-steve.glendinning@smsc.com>
	 <1232010482-3744-3-git-send-email-steve.glendinning@smsc.com>
	 <1232010482-3744-4-git-send-email-steve.glendinning@smsc.com>
	 <1232010482-3744-5-git-send-email-steve.glendinning@smsc.com>
	 <1232010482-3744-6-git-send-email-steve.glendinning@smsc.com>
Reply-To: stanley.miao@windriver.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Ian Saturley <ian.saturley@smsc.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37699 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755523AbZAOJPg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 04:15:36 -0500
In-Reply-To: <1232010482-3744-6-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch should be sent to linux-omap mail list. But linux-omap git
tree is still in 2.6.28 and it doesn't have smsc911x driver.

Stanley.

On Thu, 2009-01-15 at 09:08 +0000, Steve Glendinning wrote:
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> ---
>  arch/arm/configs/omap_ldp_defconfig         |   24 ++++++++++++++-
>  arch/arm/mach-omap2/board-ldp.c             |   41 +++++++++++++++++----------
>  arch/arm/plat-omap/include/mach/board-ldp.h |    4 +-
>  3 files changed, 50 insertions(+), 19 deletions(-)
> 
> diff --git a/arch/arm/configs/omap_ldp_defconfig b/arch/arm/configs/omap_ldp_defconfig
> index b77d054..c164ff2 100644
> --- a/arch/arm/configs/omap_ldp_defconfig
> +++ b/arch/arm/configs/omap_ldp_defconfig
> @@ -474,14 +474,34 @@ CONFIG_NETDEVICES=y
>  # CONFIG_EQUALIZER is not set
>  # CONFIG_TUN is not set
>  # CONFIG_VETH is not set
> -# CONFIG_PHYLIB is not set
> +CONFIG_PHYLIB=y
> +
> +#
> +# MII PHY device drivers
> +#
> +# CONFIG_MARVELL_PHY is not set
> +# CONFIG_DAVICOM_PHY is not set
> +# CONFIG_QSEMI_PHY is not set
> +# CONFIG_LXT_PHY is not set
> +# CONFIG_CICADA_PHY is not set
> +# CONFIG_VITESSE_PHY is not set
> +CONFIG_SMSC_PHY=y
> +# CONFIG_BROADCOM_PHY is not set
> +# CONFIG_ICPLUS_PHY is not set
> +# CONFIG_REALTEK_PHY is not set
> +# CONFIG_NATIONAL_PHY is not set
> +# CONFIG_STE10XP is not set
> +# CONFIG_LSI_ET1011C_PHY is not set
> +# CONFIG_FIXED_PHY is not set
> +# CONFIG_MDIO_BITBANG is not set
>  CONFIG_NET_ETHERNET=y
>  CONFIG_MII=y
>  # CONFIG_AX88796 is not set
>  # CONFIG_SMC91X is not set
>  # CONFIG_DM9000 is not set
>  # CONFIG_ENC28J60 is not set
> -CONFIG_SMC911X=y
> +# CONFIG_SMC911X is not set
> +CONFIG_SMSC911X=y
>  # CONFIG_IBM_NEW_EMAC_ZMII is not set
>  # CONFIG_IBM_NEW_EMAC_RGMII is not set
>  # CONFIG_IBM_NEW_EMAC_TAH is not set
> diff --git a/arch/arm/mach-omap2/board-ldp.c b/arch/arm/mach-omap2/board-ldp.c
> index aa69727..b8810bd 100644
> --- a/arch/arm/mach-omap2/board-ldp.c
> +++ b/arch/arm/mach-omap2/board-ldp.c
> @@ -22,6 +22,7 @@
>  #include <linux/spi/spi.h>
>  #include <linux/spi/ads7846.h>
>  #include <linux/i2c/twl4030.h>
> +#include <linux/smsc911x.h>
>  
>  #include <mach/hardware.h>
>  #include <asm/mach-types.h>
> @@ -43,7 +44,7 @@
>  
>  #define SDP3430_SMC91X_CS	3
>  
> -static struct resource ldp_smc911x_resources[] = {
> +static struct resource ldp_smsc911x_resources[] = {
>  	[0] = {
>  		.start	= OMAP34XX_ETHR_START,
>  		.end	= OMAP34XX_ETHR_START + SZ_4K,
> @@ -56,40 +57,50 @@ static struct resource ldp_smc911x_resources[] = {
>  	},
>  };
>  
> -static struct platform_device ldp_smc911x_device = {
> -	.name		= "smc911x",
> +static struct smsc911x_platform_config ldp_smsc911x_config = {
> +	.irq_polarity	= SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
> +	.irq_type	= SMSC911X_IRQ_TYPE_OPEN_DRAIN,
> +	.flags		= SMSC911X_USE_32BIT,
> +	.phy_interface	= PHY_INTERFACE_MODE_MII,
> +};
> +
> +static struct platform_device ldp_smsc911x_device = {
> +	.name		= "smsc911x",
>  	.id		= -1,
> -	.num_resources	= ARRAY_SIZE(ldp_smc911x_resources),
> -	.resource	= ldp_smc911x_resources,
> +	.num_resources	= ARRAY_SIZE(ldp_smsc911x_resources),
> +	.resource	= ldp_smsc911x_resources,
> +	.dev		= {
> +		.platform_data = &ldp_smsc911x_config,
> +	},
>  };
>  
>  static struct platform_device *ldp_devices[] __initdata = {
> -	&ldp_smc911x_device,
> +	&ldp_smsc911x_device,
>  };
>  
> -static inline void __init ldp_init_smc911x(void)
> +static inline void __init ldp_init_smsc911x(void)
>  {
>  	int eth_cs;
>  	unsigned long cs_mem_base;
>  	int eth_gpio = 0;
>  
> -	eth_cs = LDP_SMC911X_CS;
> +	eth_cs = LDP_SMSC911X_CS;
>  
>  	if (gpmc_cs_request(eth_cs, SZ_16M, &cs_mem_base) < 0) {
> -		printk(KERN_ERR "Failed to request GPMC mem for smc911x\n");
> +		printk(KERN_ERR "Failed to request GPMC mem for smsc911x\n");
>  		return;
>  	}
>  
> -	ldp_smc911x_resources[0].start = cs_mem_base + 0x0;
> -	ldp_smc911x_resources[0].end   = cs_mem_base + 0xf;
> +	ldp_smsc911x_resources[0].start = cs_mem_base + 0x0;
> +	ldp_smsc911x_resources[0].end   = cs_mem_base + 0xf;
>  	udelay(100);
>  
> -	eth_gpio = LDP_SMC911X_GPIO;
> +	eth_gpio = LDP_SMSC911X_GPIO;
>  
> -	ldp_smc911x_resources[1].start = OMAP_GPIO_IRQ(eth_gpio);
> +	ldp_smsc911x_resources[1].start = OMAP_GPIO_IRQ(eth_gpio);
>  
>  	if (omap_request_gpio(eth_gpio) < 0) {
> -		printk(KERN_ERR "Failed to request GPIO%d for smc911x IRQ\n",
> +		printk(KERN_ERR "Failed to request GPIO%d for smsc911x IRQ\n",
>  				eth_gpio);
>  		return;
>  	}
> @@ -101,7 +112,7 @@ static void __init omap_ldp_init_irq(void)
>  	omap2_init_common_hw();
>  	omap_init_irq();
>  	omap_gpio_init();
> -	ldp_init_smc911x();
> +	ldp_init_smsc911x();
>  }
>  
>  static struct omap_uart_config ldp_uart_config __initdata = {
> diff --git a/arch/arm/plat-omap/include/mach/board-ldp.h b/arch/arm/plat-omap/include/mach/board-ldp.h
> index f233996..74e98eb 100644
> --- a/arch/arm/plat-omap/include/mach/board-ldp.h
> +++ b/arch/arm/plat-omap/include/mach/board-ldp.h
> @@ -32,8 +32,8 @@
>  extern void twl4030_bci_battery_init(void);
>  
>  #define TWL4030_IRQNUM		INT_34XX_SYS_NIRQ
> -#define LDP_SMC911X_CS         1
> -#define LDP_SMC911X_GPIO       152
> +#define LDP_SMSC911X_CS        1
> +#define LDP_SMSC911X_GPIO      152
>  #define DEBUG_BASE             0x08000000
>  #define OMAP34XX_ETHR_START    DEBUG_BASE
>  #endif /* __ASM_ARCH_OMAP_LDP_H */
