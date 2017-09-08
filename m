From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 2/3] net: ethernet: socionext: add AVE ethernet
 driver
Date: Fri, 8 Sep 2017 12:31:18 -0700
Message-ID: <df4ec8b2-67cf-5dee-2600-88cffd1bcd11@gmail.com>
References: <1504875731-3680-1-git-send-email-hayashi.kunihiko@socionext.com>
 <1504875731-3680-3-git-send-email-hayashi.kunihiko@socionext.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
        Masami Hiramatsu <masami.hiramatsu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1504875731-3680-3-git-send-email-hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/08/2017 06:02 AM, Kunihiko Hayashi wrote:
> The UniPhier platform from Socionext provides the AVE ethernet
> controller that includes MAC and MDIO bus supporting RGMII/RMII
> modes. The controller is named AVE.
> 
> Signed-off-by: Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
> Signed-off-by: Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
>  drivers/net/ethernet/Kconfig             |    1 +
>  drivers/net/ethernet/Makefile            |    1 +
>  drivers/net/ethernet/socionext/Kconfig   |   22 +
>  drivers/net/ethernet/socionext/Makefile  |    4 +
>  drivers/net/ethernet/socionext/sni_ave.c | 1618 ++++++++++++++++++++++++++++++
>  5 files changed, 1646 insertions(+)
>  create mode 100644 drivers/net/ethernet/socionext/Kconfig
>  create mode 100644 drivers/net/ethernet/socionext/Makefile
>  create mode 100644 drivers/net/ethernet/socionext/sni_ave.c
> 
> diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
> index c604213..d50519e 100644
> --- a/drivers/net/ethernet/Kconfig
> +++ b/drivers/net/ethernet/Kconfig
> @@ -170,6 +170,7 @@ source "drivers/net/ethernet/sis/Kconfig"
>  source "drivers/net/ethernet/sfc/Kconfig"
>  source "drivers/net/ethernet/sgi/Kconfig"
>  source "drivers/net/ethernet/smsc/Kconfig"
> +source "drivers/net/ethernet/socionext/Kconfig"
>  source "drivers/net/ethernet/stmicro/Kconfig"
>  source "drivers/net/ethernet/sun/Kconfig"
>  source "drivers/net/ethernet/tehuti/Kconfig"
> diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
> index a0a03d4..9f55b36 100644
> --- a/drivers/net/ethernet/Makefile
> +++ b/drivers/net/ethernet/Makefile
> @@ -81,6 +81,7 @@ obj-$(CONFIG_SFC) += sfc/
>  obj-$(CONFIG_SFC_FALCON) += sfc/falcon/
>  obj-$(CONFIG_NET_VENDOR_SGI) += sgi/
>  obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
> +obj-$(CONFIG_NET_VENDOR_SOCIONEXT) += socionext/
>  obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
>  obj-$(CONFIG_NET_VENDOR_SUN) += sun/
>  obj-$(CONFIG_NET_VENDOR_TEHUTI) += tehuti/
> diff --git a/drivers/net/ethernet/socionext/Kconfig b/drivers/net/ethernet/socionext/Kconfig
> new file mode 100644
> index 0000000..788f26f
> --- /dev/null
> +++ b/drivers/net/ethernet/socionext/Kconfig
> @@ -0,0 +1,22 @@
> +config NET_VENDOR_SOCIONEXT
> +	bool "Socionext ethernet drivers"
> +	default y
> +	---help---
> +	  Option to select ethernet drivers for Socionext platforms.
> +
> +	  Note that the answer to this question doesn't directly affect the
> +	  kernel: saying N will just cause the configurator to skip all
> +	  the questions about Agere devices. If you say Y, you will be asked
> +	  for your specific card in the following questions.
> +
> +if NET_VENDOR_SOCIONEXT
> +
> +config SNI_AVE
> +	tristate "Socionext AVE ethernet support"
> +	depends on (ARCH_UNIPHIER || COMPILE_TEST) && OF
> +	select PHYLIB
> +	---help---
> +	  Driver for gigabit ethernet MACs, called AVE, in the
> +	  Socionext UniPhier family.
> +
> +endif #NET_VENDOR_SOCIONEXT
> diff --git a/drivers/net/ethernet/socionext/Makefile b/drivers/net/ethernet/socionext/Makefile
> new file mode 100644
> index 0000000..0356341
> --- /dev/null
> +++ b/drivers/net/ethernet/socionext/Makefile
> @@ -0,0 +1,4 @@
> +#
> +# Makefile for all ethernet ip drivers on Socionext platforms
> +#
> +obj-$(CONFIG_SNI_AVE) += sni_ave.o
> diff --git a/drivers/net/ethernet/socionext/sni_ave.c b/drivers/net/ethernet/socionext/sni_ave.c
> new file mode 100644
> index 0000000..c870777
> --- /dev/null
> +++ b/drivers/net/ethernet/socionext/sni_ave.c
> @@ -0,0 +1,1618 @@
> +/**
> + * sni_ave.c - Socionext UniPhier AVE ethernet driver
> + *
> + * Copyright 2014 Panasonic Corporation
> + * Copyright 2015-2017 Socionext Inc.
> + *
> + * This program is free software: you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2  of
> + * the License as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +
> +#include <linux/bitops.h>
> +#include <linux/clk.h>
> +#include <linux/etherdevice.h>
> +#include <linux/interrupt.h>
> +#include <linux/io.h>
> +#include <linux/mii.h>
> +#include <linux/module.h>
> +#include <linux/netdevice.h>
> +#include <linux/of_net.h>
> +#include <linux/of_mdio.h>
> +#include <linux/of_platform.h>
> +#include <linux/phy.h>
> +#include <linux/reset.h>
> +#include <linux/types.h>
> +
> +/* General Register Group */
> +#define AVE_IDR		0x0	/* ID */
> +#define AVE_VR		0x4	/* Version */
> +#define AVE_GRR		0x8	/* Global Reset */
> +#define AVE_CFGR	0xc	/* Configuration */
> +
> +/* Interrupt Register Group */
> +#define AVE_GIMR	0x100	/* Global Interrupt Mask */
> +#define AVE_GISR	0x104	/* Global Interrupt Status */
> +
> +/* MAC Register Group */
> +#define AVE_TXCR	0x200	/* TX Setup */
> +#define AVE_RXCR	0x204	/* RX Setup */
> +#define AVE_RXMAC1R	0x208	/* MAC address (lower) */
> +#define AVE_RXMAC2R	0x20c	/* MAC address (upper) */
> +#define AVE_MDIOCTR	0x214	/* MDIO Control */
> +#define AVE_MDIOAR	0x218	/* MDIO Address */
> +#define AVE_MDIOWDR	0x21c	/* MDIO Data */
> +#define AVE_MDIOSR	0x220	/* MDIO Status */
> +#define AVE_MDIORDR	0x224	/* MDIO Rd Data */
> +
> +/* Descriptor Control Register Group */
> +#define AVE_DESCC	0x300	/* Descriptor Control */
> +#define AVE_TXDC	0x304	/* TX Descriptor Configuration */
> +#define AVE_RXDC0	0x308	/* RX Descriptor Ring0 Configuration */
> +#define AVE_IIRQC	0x34c	/* Interval IRQ Control */
> +
> +/* Frame Counter Register Group */
> +#define AVE_BFCR	0x400	/* Bad Frame Counter */
> +#define AVE_RX0OVFFC	0x414	/* OVF Frame Counter (Ring0) */
> +#define AVE_SN5FC	0x438	/* Frame Counter No5 */
> +#define AVE_SN6FC	0x43c	/* Frame Counter No6 */
> +#define AVE_SN7FC	0x440	/* Frame Counter No7 */
> +
> +/* Packet Filter Register Group */
> +#define AVE_PKTF_BASE		0x800	/* PF Base Address */
> +#define AVE_PFMBYTE_BASE	0xd00	/* PF Mask Byte Base Address */
> +#define AVE_PFMBIT_BASE		0xe00	/* PF Mask Bit Base Address */
> +#define AVE_PFSEL_BASE		0xf00	/* PF Selector Base Address */
> +#define AVE_PFEN		0xffc	/* Packet Filter Enable */
> +#define AVE_PKTF(ent)		(AVE_PKTF_BASE + (ent) * 0x40)
> +#define AVE_PFMBYTE(ent)	(AVE_PFMBYTE_BASE + (ent) * 8)
> +#define AVE_PFMBIT(ent)		(AVE_PFMBIT_BASE + (ent) * 4)
> +#define AVE_PFSEL(ent)		(AVE_PFSEL_BASE + (ent) * 4)
> +
> +/* 64bit descriptor memory */
> +#define AVE_DESC_SIZE_64	12	/* Descriptor Size */
> +
> +#define AVE_TXDM_64		0x1000	/* Tx Descriptor Memory */
> +#define AVE_RXDM_64		0x1c00	/* Rx Descriptor Memory */
> +
> +#define AVE_TXDM_SIZE_64	0x0ba0	/* Tx Descriptor Memory Size 3KB */
> +#define AVE_RXDM_SIZE_64	0x6000	/* Rx Descriptor Memory Size 24KB */
> +
> +/* 32bit descriptor memory */
> +#define AVE_DESC_SIZE_32	8	/* Descriptor Size */
> +
> +#define AVE_TXDM_32		0x1000	/* Tx Descriptor Memory */
> +#define AVE_RXDM_32		0x1800	/* Rx Descriptor Memory */
> +
> +#define AVE_TXDM_SIZE_32	0x07c0	/* Tx Descriptor Memory Size 2KB */
> +#define AVE_RXDM_SIZE_32	0x4000	/* Rx Descriptor Memory Size 16KB */
> +
> +/* RMII Bridge Register Group */
> +#define AVE_RSTCTRL		0x8028	/* Reset control */
> +#define AVE_RSTCTRL_RMIIRST	BIT(16)
> +#define AVE_LINKSEL		0x8034	/* Link speed setting */
> +#define AVE_LINKSEL_100M	BIT(0)
> +
> +/* AVE_GRR */
> +#define AVE_GRR_RXFFR		BIT(5)	/* Reset RxFIFO */
> +#define AVE_GRR_PHYRST		BIT(4)	/* Reset external PHY */
> +#define AVE_GRR_GRST		BIT(0)	/* Reset all MAC */
> +
> +/* AVE_GISR (common with GIMR) */
> +#define AVE_GI_PHY		BIT(24)	/* PHY interrupt */
> +#define AVE_GI_TX		BIT(16)	/* Tx complete */
> +#define AVE_GI_RXERR		BIT(8)	/* Receive frame more than max size */
> +#define AVE_GI_RXOVF		BIT(7)	/* Overflow at the RxFIFO */
> +#define AVE_GI_RXDROP		BIT(6)	/* Drop packet */
> +#define AVE_GI_RXIINT		BIT(5)	/* Interval interrupt */
> +
> +/* AVE_TXCR */
> +#define AVE_TXCR_FLOCTR		BIT(18)	/* Flow control */
> +#define AVE_TXCR_TXSPD_1G	BIT(17)
> +#define AVE_TXCR_TXSPD_100	BIT(16)
> +
> +/* AVE_RXCR */
> +#define AVE_RXCR_RXEN		BIT(30)	/* Rx enable */
> +#define AVE_RXCR_FDUPEN		BIT(22)	/* Interface mode */
> +#define AVE_RXCR_FLOCTR		BIT(21)	/* Flow control */
> +#define AVE_RXCR_AFEN		BIT(19)	/* MAC address filter */
> +#define AVE_RXCR_DRPEN		BIT(18)	/* Drop pause frame */
> +#define AVE_RXCR_MPSIZ_MASK	GENMASK(10, 0)
> +
> +/* AVE_MDIOCTR */
> +#define AVE_MDIOCTR_RREQ	BIT(3)	/* Read request */
> +#define AVE_MDIOCTR_WREQ	BIT(2)	/* Write request */
> +
> +/* AVE_MDIOSR */
> +#define AVE_MDIOSR_STS		BIT(0)	/* access status */
> +
> +/* AVE_DESCC */
> +#define AVE_DESCC_TD		BIT(0)	/* Enable Tx descriptor */
> +#define AVE_DESCC_RDSTP		BIT(4)	/* Pause Rx descriptor */
> +#define AVE_DESCC_RD0		BIT(8)	/* Enable Rx descriptor Ring0 */
> +
> +#define AVE_DESCC_CTRL_MASK	GENMASK(15, 0)
> +
> +/* AVE_TXDC */
> +#define AVE_TXDC_SIZE		GENMASK(27, 16)	/* Size of Tx descriptor */
> +#define AVE_TXDC_ADDR		GENMASK(11, 0)	/* Start address */
> +#define AVE_TXDC_ADDR_START	0
> +
> +/* AVE_RXDC0 */
> +#define AVE_RXDC0_SIZE		GENMASK(30, 16)	/* Size of Rx descriptor */
> +#define AVE_RXDC0_ADDR		GENMASK(14, 0)	/* Start address */
> +#define AVE_RXDC0_ADDR_START	0
> +
> +/* AVE_IIRQC */
> +#define AVE_IIRQC_EN0		BIT(27)	/* Enable interval interrupt Ring0 */
> +#define AVE_IIRQC_BSCK		GENMASK(15, 0)	/* Interval count unit */
> +
> +/* Command status for Descriptor */
> +#define AVE_STS_OWN		BIT(31)	/* Descriptor ownership */
> +#define AVE_STS_INTR		BIT(29)	/* Request for interrupt */
> +#define AVE_STS_OK		BIT(27)	/* Normal transmit */
> +/* TX */
> +#define AVE_STS_NOCSUM		BIT(28)	/* No use HW checksum */
> +#define AVE_STS_1ST		BIT(26)	/* Head of buffer chain */
> +#define AVE_STS_LAST		BIT(25)	/* Tail of buffer chain */
> +#define AVE_STS_OWC		BIT(21)	/* Out of window,Late Collision */
> +#define AVE_STS_EC		BIT(20)	/* Excess collision occurred */
> +#define AVE_STS_PKTLEN_TX	GENMASK(15, 0)
> +/* RX */
> +#define AVE_STS_CSSV		BIT(21)	/* Checksum check performed */
> +#define AVE_STS_CSER		BIT(20)	/* Checksum error detected */
> +#define AVE_STS_PKTLEN_RX	GENMASK(10, 0)
> +
> +/* AVE_CFGR */
> +#define AVE_CFGR_FLE		BIT(31)	/* Filter Function */
> +#define AVE_CFGR_CHE		BIT(30)	/* Checksum Function */
> +#define AVE_CFGR_MII		BIT(27)	/* Func mode (1:MII/RMII, 0:RGMII) */
> +#define AVE_CFGR_IPFCEN		BIT(24)	/* IP fragment sum Enable */
> +
> +#define AVE_MAX_ETHFRAME	1518
> +
> +/* Packet filter size */
> +#define AVE_PF_SIZE		17	/* Number of all packet filter */
> +#define AVE_PF_MULTICAST_SIZE	7	/* Number of multicast filter */
> +
> +/* Packet filter definition */
> +#define AVE_PFNUM_FILTER	0	/* No.0 */
> +#define AVE_PFNUM_UNICAST	1	/* No.1 */
> +#define AVE_PFNUM_BROADCAST	2	/* No.2 */
> +#define AVE_PFNUM_MULTICAST	11	/* No.11-17 */
> +
> +/* NETIF Message control */
> +#define AVE_DEFAULT_MSG_ENABLE	(NETIF_MSG_DRV    |	\
> +				 NETIF_MSG_PROBE  |	\
> +				 NETIF_MSG_LINK   |	\
> +				 NETIF_MSG_TIMER  |	\
> +				 NETIF_MSG_IFDOWN |	\
> +				 NETIF_MSG_IFUP   |	\
> +				 NETIF_MSG_RX_ERR |	\
> +				 NETIF_MSG_TX_ERR)
> +
> +/* Parameter for descriptor */
> +#define AVE_NR_TXDESC		32	/* Tx descriptor */
> +#define AVE_NR_RXDESC		64	/* Rx descriptor */
> +
> +/* Parameter for interrupt */
> +#define AVE_INTM_COUNT		20
> +#define AVE_FORCE_TXINTCNT	1
> +
> +#define IS_DESC_64BIT(p)	((p)->desc_size == AVE_DESC_SIZE_64)
> +
> +enum desc_id {
> +	AVE_DESCID_TX = 0,
> +	AVE_DESCID_RX,
> +};
> +
> +enum desc_state {
> +	AVE_DESC_STOP = 0,
> +	AVE_DESC_START,
> +	AVE_DESC_RX_SUSPEND,
> +	AVE_DESC_RX_PERMIT,
> +};
> +
> +struct ave_desc {
> +	struct sk_buff	*skbs;
> +	dma_addr_t	skbs_dma;
> +	size_t		skbs_dmalen;
> +};
> +
> +struct ave_desc_info {
> +	u32	ndesc;		/* number of descriptor */
> +	u32	daddr;		/* start address of descriptor */
> +	u32	proc_idx;	/* index of processing packet */
> +	u32	done_idx;	/* index of processed packet */
> +	struct ave_desc *desc;	/* skb info related descriptor */
> +};
> +
> +struct ave_private {
> +	int			phy_id;
> +	unsigned int		desc_size;
> +	u32			msg_enable;
> +	struct clk		*clk;
> +	phy_interface_t		phy_mode;
> +	struct phy_device	*phydev;
> +	struct mii_bus		*mdio;
> +	struct net_device_stats	stats;
> +	bool			internal_phy_interrupt;
> +
> +	/* NAPI support */
> +	struct net_device	*ndev;
> +	struct napi_struct	napi_rx;
> +	struct napi_struct	napi_tx;
> +
> +	/* descriptor */
> +	struct ave_desc_info	rx;
> +	struct ave_desc_info	tx;
> +};
> +
> +static inline u32 ave_r32(struct net_device *ndev, u32 offset)
> +{
> +	void __iomem *addr = (void __iomem *)ndev->base_addr;
> +
> +	return readl_relaxed(addr + offset);
> +}

Don't do this, ndev->base_addr is convenient, but is now deprecated
(unlike ISA cards, you can't change this anymore) instead, just pass a
reference to an ave_private structure and store the base register
pointer there.

> +
> +static inline void ave_w32(struct net_device *ndev, u32 offset, u32 value)
> +{
> +	void __iomem *addr = (void __iomem *)ndev->base_addr;
> +
> +	writel_relaxed(value, addr + offset);
> +}

Same here.

> +
> +static inline u32 ave_rdesc(struct net_device *ndev, enum desc_id id,
> +			    int entry, int offset)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +	u32 addr = (id == AVE_DESCID_TX) ? priv->tx.daddr : priv->rx.daddr;
> +
> +	addr += entry * priv->desc_size + offset;
> +
> +	return ave_r32(ndev, addr);
> +}
> +
> +static inline void ave_wdesc(struct net_device *ndev, enum desc_id id,
> +			     int entry, int offset, u32 val)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +	u32 addr = (id == AVE_DESCID_TX) ? priv->tx.daddr : priv->rx.daddr;
> +
> +	addr += entry * priv->desc_size + offset;
> +
> +	ave_w32(ndev, addr, val);
> +}
> +
> +static void ave_wdesc_addr(struct net_device *ndev, enum desc_id id,
> +			   int entry, int offset, dma_addr_t paddr)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +
> +	ave_wdesc(ndev, id, entry, offset, (u32)((u64)paddr & 0xFFFFFFFFULL));

lower_32_bits()

> +	if (IS_DESC_64BIT(priv))
> +		ave_wdesc(ndev, id,
> +			  entry, offset + 4, (u32)((u64)paddr >> 32));

upper_32_bits()

> +	else if ((u64)paddr > (u64)U32_MAX)
> +		netdev_warn(ndev, "DMA address exceeds the address space\n");
> +}
> +
> +static void ave_get_fwversion(struct net_device *ndev, char *buf, int len)
> +{
> +	u32 major, minor;
> +
> +	major = (ave_r32(ndev, AVE_VR) & GENMASK(15, 8)) >> 8;
> +	minor = (ave_r32(ndev, AVE_VR) & GENMASK(7, 0));
> +	snprintf(buf, len, "v%u.%u", major, minor);
> +}
> +
> +static void ave_get_drvinfo(struct net_device *ndev,
> +			    struct ethtool_drvinfo *info)
> +{
> +	struct device *dev = ndev->dev.parent;
> +
> +	strlcpy(info->driver, dev->driver->name, sizeof(info->driver));
> +	strlcpy(info->bus_info, dev_name(dev), sizeof(info->bus_info));

bus_info would likely be platform, since this is a memory mapped
peripheral, right?

> +	ave_get_fwversion(ndev, info->fw_version, sizeof(info->fw_version));
> +}
> +
> +static int ave_nway_reset(struct net_device *ndev)
> +{
> +	return genphy_restart_aneg(ndev->phydev);
> +}

You can just set your ethtool_ops::nway_reset to be
phy_ethtool_nway_reset() which does additional checks.

> +
> +static u32 ave_get_link(struct net_device *ndev)
> +{
> +	int err;
> +
> +	err = genphy_update_link(ndev->phydev);
> +	if (err)
> +		return ethtool_op_get_link(ndev);

No, calling genphy_update_link() is bogus see:

e69e46261063a25c3907bed16a2e9d18b115d1fd ("net: dsa: Do not clobber PHY
link outside of state machine")

> +
> +	return ndev->phydev->link;

This can just be ethtool_op_get_link()

> +}
> +
> +static u32 ave_get_msglevel(struct net_device *ndev)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +
> +	return priv->msg_enable;
> +}
> +
> +static void ave_set_msglevel(struct net_device *ndev, u32 val)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +
> +	priv->msg_enable = val;
> +}
> +
> +static void ave_get_wol(struct net_device *ndev,
> +			struct ethtool_wolinfo *wol)
> +{
> +	wol->supported = 0;
> +	wol->wolopts   = 0;
> +	phy_ethtool_get_wol(ndev->phydev, wol);

This can be called before you successfully connected to a PHY so you
need to check that ndev->phydev is not NULL at the very least.

> +}
> +
> +static int ave_set_wol(struct net_device *ndev,
> +		       struct ethtool_wolinfo *wol)
> +{
> +	if (wol->wolopts & (WAKE_ARP | WAKE_MAGICSECURE))
> +		return -EOPNOTSUPP;
> +
> +	return phy_ethtool_set_wol(ndev->phydev, wol);

Same here.


> +
> +static int ave_mdio_busywait(struct net_device *ndev)
> +{
> +	int ret = 1, loop = 100;
> +	u32 mdiosr;
> +
> +	/* wait until completion */
> +	while (1) {

Since you are already bound by the number of times you allow this look,
just make that a clear condition for the while() loop to exit.

> +		mdiosr = ave_r32(ndev, AVE_MDIOSR);
> +		if (!(mdiosr & AVE_MDIOSR_STS))
> +			break;
> +
> +		usleep_range(10, 20);
> +		if (!loop--) {
> +			netdev_err(ndev,
> +				   "failed to read from MDIO (status:0x%08x)\n",
> +				   mdiosr);
> +			ret = 0;
> +			break;
> +		}
> +	}
> +
> +	return ret;
> +}
> +
> +static int ave_mdiobus_read(struct mii_bus *bus, int phyid, int regnum)
> +{
> +	struct net_device *ndev = bus->priv;
> +	u32 mdioctl;
> +
> +	/* write address */
> +	ave_w32(ndev, AVE_MDIOAR, (phyid << 8) | regnum);
> +
> +	/* read request */
> +	mdioctl = ave_r32(ndev, AVE_MDIOCTR);
> +	ave_w32(ndev, AVE_MDIOCTR, mdioctl | AVE_MDIOCTR_RREQ);
> +
> +	if (!ave_mdio_busywait(ndev)) {
> +		netdev_err(ndev, "phy-%d reg-%x read failed\n",
> +			   phyid, regnum);
> +		return 0xffff;
> +	}
> +
> +	return ave_r32(ndev, AVE_MDIORDR) & GENMASK(15, 0);
> +}
> +
> +static int ave_mdiobus_write(struct mii_bus *bus,
> +			     int phyid, int regnum, u16 val)
> +{
> +	struct net_device *ndev = bus->priv;
> +	u32 mdioctl;
> +
> +	/* write address */
> +	ave_w32(ndev, AVE_MDIOAR, (phyid << 8) | regnum);
> +
> +	/* write data */
> +	ave_w32(ndev, AVE_MDIOWDR, val);
> +
> +	/* write request */
> +	mdioctl = ave_r32(ndev, AVE_MDIOCTR);
> +	ave_w32(ndev, AVE_MDIOCTR, mdioctl | AVE_MDIOCTR_WREQ);
> +
> +	if (!ave_mdio_busywait(ndev)) {
> +		netdev_err(ndev, "phy-%d reg-%x write failed\n",
> +			   phyid, regnum);
> +		return -1;
> +	}

Just propagate the return value of ave_mdio_busywait().

> +
> +	return 0;
> +}
> +
> +static dma_addr_t ave_dma_map(struct net_device *ndev, struct ave_desc *desc,
> +			      void *ptr, size_t len,
> +			      enum dma_data_direction dir)
> +{
> +	dma_addr_t paddr;
> +
> +	paddr = dma_map_single(ndev->dev.parent, ptr, len, dir);
> +	if (dma_mapping_error(ndev->dev.parent, paddr)) {
> +		desc->skbs_dma = 0;
> +		paddr = (dma_addr_t)virt_to_phys(ptr);

Why do you do that? If dma_map_single() failed, that's it, game over,
you need to discad the packet, not assume that it is in the kernel's
linear mapping!

> +	} else {
> +		desc->skbs_dma = paddr;
> +		desc->skbs_dmalen = len;
> +	}
> +
> +	return paddr;
> +}
> +
> +static void ave_dma_unmap(struct net_device *ndev, struct ave_desc *desc,
> +			  enum dma_data_direction dir)
> +{
> +	if (!desc->skbs_dma)
> +		return;
> +
> +	dma_unmap_single(ndev->dev.parent,
> +			 desc->skbs_dma, desc->skbs_dmalen, dir);
> +	desc->skbs_dma = 0;
> +}
> +
> +/* Set Rx descriptor and memory */
> +static int ave_set_rxdesc(struct net_device *ndev, int entry)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +	struct sk_buff *skb;
> +	unsigned long align;
> +	dma_addr_t paddr;
> +	void *buffptr;
> +	int ret = 0;
> +
> +	skb = priv->rx.desc[entry].skbs;
> +	if (!skb) {
> +		skb = netdev_alloc_skb_ip_align(ndev,
> +						AVE_MAX_ETHFRAME + NET_SKB_PAD);
> +		if (!skb) {
> +			netdev_err(ndev, "can't allocate skb for Rx\n");
> +			return -ENOMEM;
> +		}
> +	}
> +
> +	/* set disable to cmdsts */
> +	ave_wdesc(ndev, AVE_DESCID_RX, entry, 0, AVE_STS_INTR | AVE_STS_OWN);
> +
> +	/* align skb data for cache size */
> +	align = (unsigned long)skb_tail_pointer(skb) & (NET_SKB_PAD - 1);
> +	align = NET_SKB_PAD - align;
> +	skb_reserve(skb, align);
> +	buffptr = (void *)skb_tail_pointer(skb);

Are you positive you need this? Because by default, the networking stack
will align to the maximum between your L1 cache line size and 64 bytes,
which should be a pretty good alignment guarantee.

> +
> +	paddr = ave_dma_map(ndev, &priv->rx.desc[entry], buffptr,
> +			    AVE_MAX_ETHFRAME + NET_IP_ALIGN, DMA_FROM_DEVICE);

This needs to be checked, as mentioned before, you can't just assume the
linear virtual map is going to be satisfactory.

> +	priv->rx.desc[entry].skbs = skb;
> +
> +	/* set buffer pointer */
> +	ave_wdesc_addr(ndev, AVE_DESCID_RX, entry, 4, paddr);

OK, so 4 is an offset, can you add a define for that so it's clear it is
not an address size instead?

> +
> +	/* set enable to cmdsts */
> +	ave_wdesc(ndev, AVE_DESCID_RX,
> +		  entry, 0, AVE_STS_INTR | AVE_MAX_ETHFRAME);
> +
> +	return ret;
> +}
> +
> +/* Switch state of descriptor */
> +static int ave_desc_switch(struct net_device *ndev, enum desc_state state)
> +{
> +	int counter;
> +	u32 val;
> +
> +	switch (state) {
> +	case AVE_DESC_START:
> +		ave_w32(ndev, AVE_DESCC, AVE_DESCC_TD | AVE_DESCC_RD0);
> +		break;
> +
> +	case AVE_DESC_STOP:
> +		ave_w32(ndev, AVE_DESCC, 0);
> +		counter = 0;
> +		while (1) {
> +			usleep_range(100, 150);
> +			if (!ave_r32(ndev, AVE_DESCC))
> +				break;
> +
> +			counter++;
> +			if (counter > 100) {
> +				netdev_err(ndev, "can't stop descriptor\n");
> +				return -EBUSY;
> +			}
> +		}

Same here, pleas rewrite the loop so the exit condition is clear.

> +		break;
> +
> +	case AVE_DESC_RX_SUSPEND:
> +		val = ave_r32(ndev, AVE_DESCC);
> +		val |= AVE_DESCC_RDSTP;
> +		val &= AVE_DESCC_CTRL_MASK;

Should not this be a &= ~AVE_DESCC_CTRL_MASK? OK maybe not.

> +		ave_w32(ndev, AVE_DESCC, val);
> +
> +		counter = 0;
> +		while (1) {
> +			usleep_range(100, 150);
> +			val = ave_r32(ndev, AVE_DESCC);
> +			if (val & (AVE_DESCC_RDSTP << 16))
> +				break;
> +
> +			counter++;
> +			if (counter > 1000) {
> +				netdev_err(ndev, "can't suspend descriptor\n");
> +				return -EBUSY;
> +			}
> +		}
> +		break;

Same here, please rewrite with the counter as an exit condition.

> +
> +	case AVE_DESC_RX_PERMIT:
> +		val = ave_r32(ndev, AVE_DESCC);
> +		val &= ~AVE_DESCC_RDSTP;
> +		val &= AVE_DESCC_CTRL_MASK;
> +		ave_w32(ndev, AVE_DESCC, val);
> +		break;
> +
> +	default:
> +		return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
> +static int ave_tx_completion(struct net_device *ndev)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +	u32 proc_idx, done_idx, ndesc, val;
> +	int freebuf_flag = 0;
> +
> +	proc_idx = priv->tx.proc_idx;
> +	done_idx = priv->tx.done_idx;
> +	ndesc    = priv->tx.ndesc;
> +
> +	/* free pre stored skb from done to proc */
> +	while (proc_idx != done_idx) {
> +		/* get cmdsts */
> +		val = ave_rdesc(ndev, AVE_DESCID_TX, done_idx, 0);
> +
> +		/* do nothing if owner is HW */
> +		if (val & AVE_STS_OWN)
> +			break;
> +
> +		/* check Tx status and updates statistics */
> +		if (val & AVE_STS_OK) {
> +			priv->stats.tx_bytes += val & AVE_STS_PKTLEN_TX;

AVE_STS_PKTLEN_TX should be suffixed with _MASK to make it clear this is
a bitmask.

> +
> +			/* success */
> +			if (val & AVE_STS_LAST)
> +				priv->stats.tx_packets++;
> +		} else {
> +			/* error */
> +			if (val & AVE_STS_LAST) {
> +				priv->stats.tx_errors++;
> +				if (val & (AVE_STS_OWC | AVE_STS_EC))
> +					priv->stats.collisions++;
> +			}
> +		}
> +
> +		/* release skb */
> +		if (priv->tx.desc[done_idx].skbs) {
> +			ave_dma_unmap(ndev, &priv->tx.desc[done_idx],
> +				      DMA_TO_DEVICE);
> +			dev_consume_skb_any(priv->tx.desc[done_idx].skbs);

Kudos for using dev_consume_skb_any()!

> +			priv->tx.desc[done_idx].skbs = NULL;
> +			freebuf_flag++;
> +		}
> +		done_idx = (done_idx + 1) % ndesc;
> +	}
> +
> +	priv->tx.done_idx = done_idx;
> +
> +	/* wake queue for freeing buffer */
> +	if (netif_queue_stopped(ndev))
> +			if (freebuf_flag)
> +				netif_wake_queue(ndev);

This can be simplified to:

	if (netif_queue_stopped(ndev) && freebuf_flag)
		netif_wake_queue(ndev)

because checking for netif_running() is implicit by actually getting
called here, this would not happen if the network interface was not
operational.

> +static irqreturn_t ave_interrupt(int irq, void *netdev)
> +{
> +	struct net_device *ndev = (struct net_device *)netdev;
> +	struct ave_private *priv = netdev_priv(ndev);
> +	u32 gimr_val, gisr_val;
> +
> +	gimr_val = ave_irq_disable_all(ndev);
> +
> +	/* get interrupt status */
> +	gisr_val = ave_r32(ndev, AVE_GISR);
> +
> +	/* PHY */
> +	if (gisr_val & AVE_GI_PHY) {
> +		ave_w32(ndev, AVE_GISR, AVE_GI_PHY);
> +		if (priv->internal_phy_interrupt)
> +			phy_mac_interrupt(ndev->phydev, ndev->phydev->link);

This is not correct you should be telling the PHY the new link state. If
you cannot, because what happens here is really that the PHY interrupt
is routed to your MAC controller, then what I would suggest doing is the
following: create an interrupt controller domain which allows the PHY
driver to manage the interrupt line using normal request_irq().


> +static int ave_poll_tx(struct napi_struct *napi, int budget)
> +{
> +	struct ave_private *priv;
> +	struct net_device *ndev;
> +	int num;
> +
> +	priv = container_of(napi, struct ave_private, napi_tx);
> +	ndev = priv->ndev;
> +
> +	num = ave_tx_completion(ndev);
> +	if (num < budget) {

TX reclamation should not be bound against the budget, always process
all packets that have been successfully submitted.

> +		napi_complete(napi);
> +
> +		/* enable Tx interrupt when NAPI finishes */
> +		ave_irq_enable(ndev, AVE_GI_TX);
> +	}
> +
> +	return num;
> +}
> +

> +static void ave_adjust_link(struct net_device *ndev)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +	struct phy_device *phydev = ndev->phydev;
> +	u32 val, txcr, rxcr, rxcr_org;
> +
> +	/* set RGMII speed */
> +	val = ave_r32(ndev, AVE_TXCR);
> +	val &= ~(AVE_TXCR_TXSPD_100 | AVE_TXCR_TXSPD_1G);
> +
> +	if (priv->phy_mode == PHY_INTERFACE_MODE_RGMII &&
> +	    phydev->speed == SPEED_1000)
> +		val |= AVE_TXCR_TXSPD_1G;

Using phy_interface_is_rgmii() would be more robust here.

> +	else if (phydev->speed == SPEED_100)
> +		val |= AVE_TXCR_TXSPD_100;
> +
> +	ave_w32(ndev, AVE_TXCR, val);
> +
> +	/* set RMII speed (100M/10M only) */
> +	if (priv->phy_mode != PHY_INTERFACE_MODE_RGMII) {

PHY_INTERFACE_MODE_MII, PHY_INTERFACE_MODE_REVMII,
PHY_INTERFACE_MODE_RMII would all qualify here presumably so you need
this check to be more restrictive to just the modes that you support.

> +		val = ave_r32(ndev, AVE_LINKSEL);
> +		if (phydev->speed == SPEED_10)
> +			val &= ~AVE_LINKSEL_100M;
> +		else
> +			val |= AVE_LINKSEL_100M;
> +		ave_w32(ndev, AVE_LINKSEL, val);
> +	}
> +
> +	/* check current RXCR/TXCR */
> +	rxcr = ave_r32(ndev, AVE_RXCR);
> +	txcr = ave_r32(ndev, AVE_TXCR);
> +	rxcr_org = rxcr;
> +
> +	if (phydev->duplex)
> +		rxcr |= AVE_RXCR_FDUPEN;
> +	else
> +		rxcr &= ~AVE_RXCR_FDUPEN;
> +
> +	if (phydev->pause) {
> +		rxcr |= AVE_RXCR_FLOCTR;
> +		txcr |= AVE_TXCR_FLOCTR;

You must also check for phydev->asym_pause and keep in mind that
phydev->pause and phydev->asym_pause reflect what the link partner
reflects, you need to implement .get_pauseparam and .set_pauseparam or
default to flow control ON (which is what you are doing here).

> +	} else {
> +		rxcr &= ~AVE_RXCR_FLOCTR;
> +		txcr &= ~AVE_TXCR_FLOCTR;
> +	}
> +
> +	if (rxcr_org != rxcr) {
> +		/* disable Rx mac */
> +		ave_w32(ndev, AVE_RXCR, rxcr & ~AVE_RXCR_RXEN);
> +		/* change and enable TX/Rx mac */
> +		ave_w32(ndev, AVE_TXCR, txcr);
> +		ave_w32(ndev, AVE_RXCR, rxcr);
> +	}
> +
> +	if (phydev->link)
> +		netif_carrier_on(ndev);
> +	else
> +		netif_carrier_off(ndev);

This is not necessary, PHYLIB is specifically taking care of that.

> +
> +	phy_print_status(phydev);
> +}
> +
> +static int ave_init(struct net_device *ndev)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +	struct device *dev = ndev->dev.parent;
> +	struct device_node *phy_node, *np = dev->of_node;
> +	struct phy_device *phydev;
> +	const void *mac_addr;
> +	u32 supported;
> +
> +	/* get mac address */
> +	mac_addr = of_get_mac_address(np);
> +	if (mac_addr)
> +		ether_addr_copy(ndev->dev_addr, mac_addr);
> +
> +	/* if the mac address is invalid, use random mac address */
> +	if (!is_valid_ether_addr(ndev->dev_addr)) {
> +		eth_hw_addr_random(ndev);
> +		dev_warn(dev, "Using random MAC address: %pM\n",
> +			 ndev->dev_addr);
> +	}
> +
> +	/* attach PHY with MAC */
> +	phy_node =  of_get_next_available_child(np, NULL);

You should be using a "phy-handle" property to connect to a designated
PHY, not the next child DT node.

> +	phydev = of_phy_connect(ndev, phy_node,
> +				ave_adjust_link, 0, priv->phy_mode);
> +	if (!phydev) {
> +		dev_err(dev, "could not attach to PHY\n");
> +		return -ENODEV;
> +	}
> +	of_node_put(phy_node);
> +
> +	priv->phydev = phydev;
> +	phydev->autoneg = AUTONEG_ENABLE;
> +	phydev->speed = 0;
> +	phydev->duplex = 0;

This is not necessary.

> +
> +	dev_info(dev, "connected to %s phy with id 0x%x\n",
> +		 phydev->drv->name, phydev->phy_id);
> +
> +	if (priv->phy_mode != PHY_INTERFACE_MODE_RGMII) {
> +		supported = phydev->supported;
> +		phydev->supported &= ~PHY_GBIT_FEATURES;
> +		phydev->supported |= supported & PHY_BASIC_FEATURES;

One of these two statements is redundant here.

> +	}
> +
> +	/* PHY interrupt stop instruction is needed because the interrupt
> +	 * continues to assert.
> +	 */
> +	phy_stop_interrupts(phydev);

Wait, what?

> +
> +	/* When PHY driver can't handle its interrupt directly,
> +	 * interrupt request always fails and polling method is used
> +	 * alternatively. In this case, the libphy says
> +	 * "libphy: uniphier-mdio: Can't get IRQ -1 (PHY)".
> +	 */
> +	phy_start_interrupts(phydev);
> +
> +	phy_start_aneg(phydev);

No, no, phy_start() would take care of all of that correctly for you,
you don't have have to do it just there because ave_open() eventually
calls phy_start() for you, so just drop these two calls.

> +
> +	return 0;
> +}
> +
> +static void ave_uninit(struct net_device *ndev)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +
> +	phy_stop_interrupts(priv->phydev);

You are missing a call to phy_stop() here, calling phy_stop_interrupts()
directly should not happen.

> +	phy_disconnect(priv->phydev);
> +}
> +
> +static int ave_open(struct net_device *ndev)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +	int entry;
> +	u32 val;
> +
> +	/* initialize Tx work */
> +	priv->tx.proc_idx = 0;
> +	priv->tx.done_idx = 0;
> +	memset(priv->tx.desc, 0, sizeof(struct ave_desc) * priv->tx.ndesc);
> +
> +	/* initialize Tx descriptor */
> +	for (entry = 0; entry < priv->tx.ndesc; entry++) {
> +		ave_wdesc(ndev, AVE_DESCID_TX, entry, 0, 0);
> +		ave_wdesc_addr(ndev, AVE_DESCID_TX, entry, 4, 0);
> +	}
> +	ave_w32(ndev, AVE_TXDC, AVE_TXDC_ADDR_START
> +		| (((priv->tx.ndesc * priv->desc_size) << 16) & AVE_TXDC_SIZE));
> +
> +	/* initialize Rx work */
> +	priv->rx.proc_idx = 0;
> +	priv->rx.done_idx = 0;
> +	memset(priv->rx.desc, 0, sizeof(struct ave_desc) * priv->rx.ndesc);
> +
> +	/* initialize Rx descriptor and buffer */
> +	for (entry = 0; entry < priv->rx.ndesc; entry++) {
> +		if (ave_set_rxdesc(ndev, entry))
> +			break;
> +	}
> +	ave_w32(ndev, AVE_RXDC0, AVE_RXDC0_ADDR_START
> +	    | (((priv->rx.ndesc * priv->desc_size) << 16) & AVE_RXDC0_SIZE));
> +
> +	/* enable descriptor */
> +	ave_desc_switch(ndev, AVE_DESC_START);
> +
> +	/* initialize filter */
> +	ave_pfsel_init(ndev);
> +
> +	/* set macaddr */
> +	val = le32_to_cpu(((u32 *)ndev->dev_addr)[0]);
> +	ave_w32(ndev, AVE_RXMAC1R, val);
> +	val = (u32)le16_to_cpu(((u16 *)ndev->dev_addr)[2]);
> +	ave_w32(ndev, AVE_RXMAC2R, val);
> +
> +	/* set Rx configuration */
> +	/* full duplex, enable pause drop, enalbe flow control */
> +	val = AVE_RXCR_RXEN | AVE_RXCR_FDUPEN | AVE_RXCR_DRPEN |
> +		AVE_RXCR_FLOCTR | (AVE_MAX_ETHFRAME & AVE_RXCR_MPSIZ_MASK);
> +	ave_w32(ndev, AVE_RXCR, val);
> +
> +	/* set Tx configuration */
> +	/* enable flow control, disable loopback */
> +	ave_w32(ndev, AVE_TXCR, AVE_TXCR_FLOCTR);
> +
> +	/* enable timer, clear EN,INTM, and mask interval unit(BSCK) */
> +	val = ave_r32(ndev, AVE_IIRQC) & AVE_IIRQC_BSCK;
> +	val |= AVE_IIRQC_EN0 | (AVE_INTM_COUNT << 16);
> +	ave_w32(ndev, AVE_IIRQC, val);
> +
> +	/* set interrupt mask */
> +	val = AVE_GI_RXIINT | AVE_GI_RXOVF | AVE_GI_TX;
> +	val |= (priv->internal_phy_interrupt) ? AVE_GI_PHY : 0;
> +	ave_irq_restore(ndev, val);
> +
> +	napi_enable(&priv->napi_rx);
> +	napi_enable(&priv->napi_tx);
> +
> +	phy_start(ndev->phydev);
> +	netif_start_queue(ndev);
> +
> +	return 0;
> +}
> +
> +static int ave_stop(struct net_device *ndev)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +	int entry;
> +
> +	/* disable all interrupt */
> +	ave_irq_disable_all(ndev);
> +	disable_irq(ndev->irq);
> +
> +	netif_tx_disable(ndev);
> +	phy_stop(ndev->phydev);
> +	napi_disable(&priv->napi_tx);
> +	napi_disable(&priv->napi_rx);
> +
> +	/* free Tx buffer */
> +	for (entry = 0; entry < priv->tx.ndesc; entry++) {
> +		if (!priv->tx.desc[entry].skbs)
> +			continue;
> +
> +		ave_dma_unmap(ndev, &priv->tx.desc[entry], DMA_TO_DEVICE);
> +		dev_kfree_skb_any(priv->tx.desc[entry].skbs);
> +		priv->tx.desc[entry].skbs = NULL;
> +	}
> +	priv->tx.proc_idx = 0;
> +	priv->tx.done_idx = 0;
> +
> +	/* free Rx buffer */
> +	for (entry = 0; entry < priv->rx.ndesc; entry++) {
> +		if (!priv->rx.desc[entry].skbs)
> +			continue;
> +
> +		ave_dma_unmap(ndev, &priv->rx.desc[entry], DMA_FROM_DEVICE);
> +		dev_kfree_skb_any(priv->rx.desc[entry].skbs);
> +		priv->rx.desc[entry].skbs = NULL;
> +	}
> +	priv->rx.proc_idx = 0;
> +	priv->rx.done_idx = 0;
> +
> +	return 0;
> +}
> +
> +static int ave_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +	u32 proc_idx, done_idx, ndesc, cmdsts;
> +	int freepkt;
> +	unsigned char *buffptr = NULL; /* buffptr for descriptor */
> +	unsigned int len;
> +	dma_addr_t paddr;
> +
> +	proc_idx = priv->tx.proc_idx;
> +	done_idx = priv->tx.done_idx;
> +	ndesc = priv->tx.ndesc;
> +	freepkt = ((done_idx + ndesc - 1) - proc_idx) % ndesc;
> +
> +	/* not enough entry, then we stop queue */
> +	if (unlikely(freepkt < 2)) {
> +		netif_stop_queue(ndev);
> +		if (unlikely(freepkt < 1))
> +			return NETDEV_TX_BUSY;
> +	}
> +
> +	priv->tx.desc[proc_idx].skbs = skb;
> +
> +	/* add padding for short packet */
> +	if (skb_padto(skb, ETH_ZLEN)) {
> +		dev_kfree_skb_any(skb);
> +		return NETDEV_TX_OK;
> +	}
> +
> +	buffptr = skb->data - NET_IP_ALIGN;
> +	len = max_t(unsigned int, ETH_ZLEN, skb->len);
> +
> +	paddr = ave_dma_map(ndev, &priv->tx.desc[proc_idx], buffptr,
> +			    len + NET_IP_ALIGN, DMA_TO_DEVICE);
> +	paddr += NET_IP_ALIGN;
> +
> +	/* set buffer address to descriptor */
> +	ave_wdesc_addr(ndev, AVE_DESCID_TX, proc_idx, 4, paddr);
> +
> +	/* set flag and length to send */
> +	cmdsts = AVE_STS_OWN | AVE_STS_1ST | AVE_STS_LAST
> +		| (len & AVE_STS_PKTLEN_TX);
> +
> +	/* set interrupt per AVE_FORCE_TXINTCNT or when queue is stopped */
> +	if (!(proc_idx % AVE_FORCE_TXINTCNT) || netif_queue_stopped(ndev))
> +		cmdsts |= AVE_STS_INTR;
> +
> +	/* disable checksum calculation when skb doesn't calurate checksum */
> +	if (skb->ip_summed == CHECKSUM_NONE ||
> +	    skb->ip_summed == CHECKSUM_UNNECESSARY)
> +		cmdsts |= AVE_STS_NOCSUM;
> +
> +	/* set cmdsts */
> +	ave_wdesc(ndev, AVE_DESCID_TX, proc_idx, 0, cmdsts);
> +
> +	priv->tx.proc_idx = (proc_idx + 1) % ndesc;
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static int ave_ioctl(struct net_device *ndev, struct ifreq *ifr, int cmd)
> +{
> +	return phy_mii_ioctl(ndev->phydev, ifr, cmd);
> +}
> +
> +static void ave_set_rx_mode(struct net_device *ndev)
> +{
> +	int count, mc_cnt = netdev_mc_count(ndev);
> +	struct netdev_hw_addr *hw_adr;
> +	u32 val;
> +	u8 v4multi_macadr[6] = { 0x01, 0x00, 0x00, 0x00, 0x00, 0x00 };
> +	u8 v6multi_macadr[6] = { 0x33, 0x00, 0x00, 0x00, 0x00, 0x00 };
> +
> +	/* MAC addr filter enable for promiscious mode */
> +	val = ave_r32(ndev, AVE_RXCR);
> +	if (ndev->flags & IFF_PROMISC || !mc_cnt)
> +		val &= ~AVE_RXCR_AFEN;
> +	else
> +		val |= AVE_RXCR_AFEN;
> +	ave_w32(ndev, AVE_RXCR, val);
> +
> +	/* set all multicast address */
> +	if ((ndev->flags & IFF_ALLMULTI) || (mc_cnt > AVE_PF_MULTICAST_SIZE)) {
> +		ave_pfsel_macaddr_set(ndev, AVE_PFNUM_MULTICAST,
> +				      v4multi_macadr, 1);
> +		ave_pfsel_macaddr_set(ndev, AVE_PFNUM_MULTICAST + 1,
> +				      v6multi_macadr, 1);
> +	} else {
> +		/* stop all multicast filter */
> +		for (count = 0; count < AVE_PF_MULTICAST_SIZE; count++)
> +			ave_pfsel_stop(ndev, AVE_PFNUM_MULTICAST + count);
> +
> +		/* set multicast addresses */
> +		count = 0;
> +		netdev_for_each_mc_addr(hw_adr, ndev) {
> +			if (count == mc_cnt)
> +				break;
> +			ave_pfsel_macaddr_set(ndev, AVE_PFNUM_MULTICAST + count,
> +					      hw_adr->addr, 6);
> +			count++;
> +		}
> +	}
> +}
> +
> +static struct net_device_stats *ave_stats(struct net_device *ndev)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +	u32 drop_num = 0;
> +
> +	priv->stats.rx_errors = ave_r32(ndev, AVE_BFCR);
> +
> +	drop_num += ave_r32(ndev, AVE_RX0OVFFC);
> +	drop_num += ave_r32(ndev, AVE_SN5FC);
> +	drop_num += ave_r32(ndev, AVE_SN6FC);
> +	drop_num += ave_r32(ndev, AVE_SN7FC);
> +	priv->stats.rx_dropped = drop_num;
> +
> +	return &priv->stats;
> +}
> +
> +static int ave_set_mac_address(struct net_device *ndev, void *p)
> +{
> +	int ret = eth_mac_addr(ndev, p);
> +	u32 val;
> +
> +	if (ret)
> +		return ret;
> +
> +	/* set macaddr */
> +	val = le32_to_cpu(((u32 *)ndev->dev_addr)[0]);
> +	ave_w32(ndev, AVE_RXMAC1R, val);
> +	val = (u32)le16_to_cpu(((u16 *)ndev->dev_addr)[2]);
> +	ave_w32(ndev, AVE_RXMAC2R, val);
> +
> +	/* pfsel unicast entry */
> +	ave_pfsel_macaddr_set(ndev, AVE_PFNUM_UNICAST, ndev->dev_addr, 6);
> +
> +	return 0;
> +}
> +
> +static const struct net_device_ops ave_netdev_ops = {
> +	.ndo_init		= ave_init,
> +	.ndo_uninit		= ave_uninit,
> +	.ndo_open		= ave_open,
> +	.ndo_stop		= ave_stop,
> +	.ndo_start_xmit		= ave_start_xmit,
> +	.ndo_do_ioctl		= ave_ioctl,
> +	.ndo_set_rx_mode	= ave_set_rx_mode,
> +	.ndo_get_stats		= ave_stats,
> +	.ndo_set_mac_address	= ave_set_mac_address,
> +};
> +
> +static int ave_probe(struct platform_device *pdev)
> +{
> +	struct device *dev = &pdev->dev;
> +	struct device_node *np = dev->of_node;
> +	u32 desc_bits, ave_id;
> +	struct reset_control *rst;
> +	struct ave_private *priv;
> +	phy_interface_t phy_mode;
> +	struct net_device *ndev;
> +	struct resource	*res;
> +	void __iomem *base;
> +	int irq, ret = 0;
> +	char buf[ETHTOOL_FWVERS_LEN];
> +
> +	/* get phy mode */
> +	phy_mode = of_get_phy_mode(np);
> +	if (phy_mode < 0) {
> +		dev_err(dev, "phy-mode not found\n");
> +		return -EINVAL;
> +	}
> +
> +	irq = platform_get_irq(pdev, 0);
> +	if (irq < 0) {
> +		dev_err(dev, "IRQ not found\n");
> +		return irq;
> +	}
> +
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	base = devm_ioremap_resource(dev, res);
> +	if (IS_ERR(base))
> +		return PTR_ERR(base);
> +
> +	/* alloc netdevice */
> +	ndev = alloc_etherdev(sizeof(struct ave_private));
> +	if (!ndev) {
> +		dev_err(dev, "can't allocate ethernet device\n");
> +		return -ENOMEM;
> +	}
> +
> +	ndev->base_addr = (unsigned long)base;

This is deprecated as mentioned earlier, just store this in
priv->base_adr or something.

> +	ndev->irq = irq;

Same here.

> +	ndev->netdev_ops = &ave_netdev_ops;
> +	ndev->ethtool_ops = &ave_ethtool_ops;
> +	SET_NETDEV_DEV(ndev, dev);
> +
> +	/* support hardware checksum */
> +	ndev->features    |= (NETIF_F_IP_CSUM | NETIF_F_RXCSUM);
> +	ndev->hw_features |= (NETIF_F_IP_CSUM | NETIF_F_RXCSUM);
> +
> +	ndev->max_mtu = AVE_MAX_ETHFRAME - (ETH_HLEN + ETH_FCS_LEN);
> +
> +	priv = netdev_priv(ndev);
> +	priv->ndev = ndev;
> +	priv->msg_enable = netif_msg_init(-1, AVE_DEFAULT_MSG_ENABLE);
> +	priv->phy_mode = phy_mode;
> +
> +	/* get bits of descriptor from devicetree */
> +	of_property_read_u32(np, "socionext,desc-bits", &desc_bits);
> +	priv->desc_size = AVE_DESC_SIZE_32;
> +	if (desc_bits == 64)
> +		priv->desc_size = AVE_DESC_SIZE_64;
> +	else if (desc_bits != 32)
> +		dev_warn(dev, "Defaulting to 32bit descriptor\n");

This should really be determined by the compatible string.

> +
> +	/* use internal phy interrupt */
> +	priv->internal_phy_interrupt =
> +		of_property_read_bool(np, "socionext,internal-phy-interrupt");

Same here.

> +
> +	/* setting private data for descriptor */
> +	priv->tx.daddr = IS_DESC_64BIT(priv) ? AVE_TXDM_64 : AVE_TXDM_32;
> +	priv->tx.ndesc = AVE_NR_TXDESC;
> +	priv->tx.desc = devm_kzalloc(dev,
> +				     sizeof(struct ave_desc) * priv->tx.ndesc,
> +				     GFP_KERNEL);
> +	if (!priv->tx.desc)
> +		return -ENOMEM;
> +
> +	priv->rx.daddr = IS_DESC_64BIT(priv) ? AVE_RXDM_64 : AVE_RXDM_32;
> +	priv->rx.ndesc = AVE_NR_RXDESC;
> +	priv->rx.desc = devm_kzalloc(dev,
> +				     sizeof(struct ave_desc) * priv->rx.ndesc,
> +				     GFP_KERNEL);
> +	if (!priv->rx.desc)
> +		return -ENOMEM;

If your network device driver is probed, but never used after that, that
is the network device is not open, you just this memory sitting for
nothing, you should consider moving that to ndo_open() time.

> +
> +	/* enable clock */
> +	priv->clk = devm_clk_get(dev, NULL);
> +	if (IS_ERR(priv->clk))
> +		priv->clk = NULL;
> +	clk_prepare_enable(priv->clk);

Same here with the clock, the block is clocked, so it can consume some
amount of power, just do the necessary HW initialization with the clock
enabled, then defer until ndo_open() before turning it back on.

> +
> +	/* reset block */
> +	rst = devm_reset_control_get(dev, NULL);
> +	if (!IS_ERR_OR_NULL(rst)) {
> +		reset_control_deassert(rst);
> +		reset_control_put(rst);
> +	}

Ah so that's interesting, you need it clocked first, then reset, I guess
that works :)

> +
> +	/* reset mac and phy */
> +	ave_global_reset(ndev);
> +
> +	/* request interrupt */
> +	ret = devm_request_irq(dev, irq, ave_interrupt,
> +			       IRQF_SHARED, ndev->name, ndev);
> +	if (ret)
> +		goto err_req_irq;

Same here, this is usually moved to ndo_open() for network drivers, but
then remember not to use devm_, just normal request_irq() because it
need to be balanced in ndo_close().

This looks like a pretty good first submission, and there does not
appear to be any obvious functional problems!
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
