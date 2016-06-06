From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: [PATCH 1/5] ethernet: add sun8i-emac driver
Date: Mon, 6 Jun 2016 09:35:29 +0800
Message-ID: <CAGb2v6432KhM5Sn3un82iAGrRMynAmFAsep=p24aLoSP+e-o8A@mail.gmail.com>
References: <1464947790-22991-1-git-send-email-clabbe.montjoie@gmail.com>
 <1464947790-22991-2-git-send-email-clabbe.montjoie@gmail.com> <5754A86B.6050607@arm.com>
Reply-To: wens-jdAy2FN1RRM@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: corentin labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>, Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
To: =?UTF-8?Q?Andr=C3=A9_Przywara?= <andre.przywara-5wv7dgnIgG8@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBB6NG2O5AKGQEYI42OJA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <5754A86B.6050607-5wv7dgnIgG8@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Mon, Jun 6, 2016 at 6:32 AM, Andr=C3=A9 Przywara <andre.przywara-5wv7dgnIgG8@public.gmane.org=
> wrote:
> On 03/06/16 10:56, LABBE Corentin wrote:
>
> Hi,
>
> first: thanks for posting this and the time and work that you spent on
> it. With the respective DT nodes this works for me on the Pine64 and
> turns this board eventually into something useful.
>
> Some comments below:
>
>> This patch add support for sun8i-emac ethernet MAC hardware.
>> It could be found in Allwinner H3/A83T/A64 SoCs.
>>
>> It supports 10/100/1000 Mbit/s speed with half/full duplex.
>> It can use an internal PHY (MII 10/100) or an external PHY
>> via RGMII/RMII.
>>
>> Signed-off-by: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>>  drivers/net/ethernet/allwinner/Kconfig      |   13 +
>>  drivers/net/ethernet/allwinner/Makefile     |    1 +
>>  drivers/net/ethernet/allwinner/sun8i-emac.c | 1943 ++++++++++++++++++++=
+++++++
>>  3 files changed, 1957 insertions(+)
>>  create mode 100644 drivers/net/ethernet/allwinner/sun8i-emac.c
>>
>> diff --git a/drivers/net/ethernet/allwinner/Kconfig b/drivers/net/ethern=
et/allwinner/Kconfig
>> index 47da7e7..226499d 100644
>> --- a/drivers/net/ethernet/allwinner/Kconfig
>> +++ b/drivers/net/ethernet/allwinner/Kconfig
>> @@ -33,4 +33,17 @@ config SUN4I_EMAC
>>            To compile this driver as a module, choose M here.  The modul=
e
>>            will be called sun4i-emac.
>>
>> +config SUN8I_EMAC
>> +        tristate "Allwinner sun8i EMAC support"
>
> nit: w/s error
>
>> +     depends on ARCH_SUNXI || COMPILE_TEST
>> +     depends on OF
>> +     select MII
>> +     select PHYLIB
>> +        ---help---
>> +       This driver support the sun8i EMAC ethernet driver present on
>> +       H3/A83T/A64 Allwinner SoCs.
>> +
>> +          To compile this driver as a module, choose M here.  The modul=
e
>> +          will be called sun8i-emac.
>> +
>>  endif # NET_VENDOR_ALLWINNER
>> diff --git a/drivers/net/ethernet/allwinner/Makefile b/drivers/net/ether=
net/allwinner/Makefile
>> index 03129f7..8bd1693c 100644
>> --- a/drivers/net/ethernet/allwinner/Makefile
>> +++ b/drivers/net/ethernet/allwinner/Makefile
>> @@ -3,3 +3,4 @@
>>  #
>>
>>  obj-$(CONFIG_SUN4I_EMAC) +=3D sun4i-emac.o
>> +obj-$(CONFIG_SUN8I_EMAC) +=3D sun8i-emac.o
>> diff --git a/drivers/net/ethernet/allwinner/sun8i-emac.c b/drivers/net/e=
thernet/allwinner/sun8i-emac.c
>> new file mode 100644
>> index 0000000..179aa61
>> --- /dev/null
>> +++ b/drivers/net/ethernet/allwinner/sun8i-emac.c
>> @@ -0,0 +1,1943 @@
>> +/*
>> + * sun8i-emac driver
>> + *
>> + * Copyright (C) 2015-2016 Corentin LABBE <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> + *
>> + * This is the driver for Allwinner Ethernet MAC found in H3/A83T/A64 S=
oC
>> + *
>> + * TODO:
>> + * - NAPI
>> + * - MAC filtering
>> + * - Jumbo frame
>> + * - features rx-all (NETIF_F_RXALL_BIT)
>> + */
>> +#include <linux/bitops.h>
>> +#include <linux/clk.h>
>> +#include <linux/dma-mapping.h>
>> +#include <linux/etherdevice.h>
>> +#include <linux/interrupt.h>
>> +#include <linux/iopoll.h>
>> +#include <linux/mii.h>
>> +#include <linux/module.h>
>> +#include <linux/netdevice.h>
>> +#include <linux/of_device.h>
>> +#include <linux/of_mdio.h>
>> +#include <linux/of_net.h>
>> +#include <linux/phy.h>
>> +#include <linux/pinctrl/consumer.h>
>> +#include <linux/pinctrl/pinctrl.h>
>> +#include <linux/platform_device.h>
>> +#include <linux/regulator/consumer.h>
>> +#include <linux/reset.h>
>> +#include <linux/scatterlist.h>
>> +#include <linux/skbuff.h>
>> +
>> +#define SUN8I_EMAC_BASIC_CTL0 0x00
>> +#define SUN8I_EMAC_BASIC_CTL1 0x04
>> +
>> +#define SUN8I_EMAC_MDIO_CMD 0x48
>> +#define SUN8I_EMAC_MDIO_DATA 0x4C
>
> Can you align all these register offsets with tabs, so that the actual
> offset values are below each other?
> Also ordering them by address seems useful to me.
>
>> +
>> +#define SUN8I_EMAC_RX_CTL0 0x24
>> +#define SUN8I_EMAC_RX_CTL1 0x28
>> +
>> +#define SUN8I_EMAC_TX_CTL0 0x10
>> +#define SUN8I_EMAC_TX_CTL1 0x14
>> +
>> +#define SUN8I_EMAC_TX_FLOW_CTL 0x1C
>> +
>> +#define SUN8I_EMAC_RX_FRM_FLT 0x38
>> +
>> +#define SUN8I_EMAC_INT_STA 0x08
>> +#define SUN8I_EMAC_INT_EN 0x0C
>> +#define SUN8I_EMAC_RGMII_STA 0xD0
>
>
>> +
>> +#define SUN8I_EMAC_TX_DMA_STA 0xB0
>> +#define SUN8I_EMAC_TX_CUR_DESC 0xB4
>> +#define SUN8I_EMAC_TX_CUR_BUF 0xB8
>> +#define SUN8I_EMAC_RX_DMA_STA 0xC0
>> +
>> +#define MDIO_CMD_MII_BUSY    BIT(0)
>> +#define MDIO_CMD_MII_WRITE   BIT(1)
>> +#define MDIO_CMD_MII_PHY_REG_ADDR_MASK       GENMASK(8, 4)
>> +#define MDIO_CMD_MII_PHY_REG_ADDR_SHIFT      4
>> +#define MDIO_CMD_MII_PHY_ADDR_MASK   GENMASK(16, 12)
>> +#define MDIO_CMD_MII_PHY_ADDR_SHIFT  12
>> +
>> +#define SUN8I_EMAC_MACADDR_HI        0x50
>> +#define SUN8I_EMAC_MACADDR_LO        0x54
>> +
>> +#define SUN8I_EMAC_RX_DESC_LIST 0x34
>> +#define SUN8I_EMAC_TX_DESC_LIST 0x20
>> +
>> +#define SUN8I_EMAC_TX_DO_CRC (BIT(27) | BIT(28))
>> +#define SUN8I_EMAC_RX_DO_CRC BIT(27)
>> +#define SUN8I_EMAC_RX_STRIP_FCS BIT(28)
>> +
>> +#define SUN8I_COULD_BE_USED_BY_DMA BIT(31)
>> +
>> +#define FLOW_RX 1
>> +#define FLOW_TX 2
>> +
>> +/* describe how data from skb are DMA mapped */
>> +#define MAP_SINGLE 1
>> +#define MAP_PAGE 2
>> +
>> +enum emac_variant {
>> +     A83T_EMAC,
>> +     H3_EMAC,
>> +     A64_EMAC,
>> +};
>> +
>> +struct ethtool_str {
>> +     char name[ETH_GSTRING_LEN];
>> +};
>> +
>> +static const struct ethtool_str estats_str[] =3D {
>> +     /* errors */
>> +     { "rx_payload_error" },
>> +     { "rx_CRC_error" },
>> +     { "rx_phy_error" },
>> +     { "rx_length_error" },
>> +     { "rx_col_error" },
>> +     { "rx_header_error" },
>> +     { "rx_overflow_error" },
>> +     { "rx_saf_error" },
>> +     { "rx_daf_error" },
>> +     { "rx_buf_error" },
>> +     /* misc infos */
>> +     { "tx_stop_queue" },
>> +     { "rx_dma_ua" },
>> +     { "rx_dma_stop" },
>> +     { "tx_dma_ua" },
>> +     { "tx_dma_stop" },
>> +     { "rx_hw_csum" },
>> +     { "tx_hw_csum" },
>> +     /* interrupts */
>> +     { "rx_early_int" },
>> +     { "tx_early_int" },
>> +     { "tx_underflow_int" },
>> +     /* debug */
>> +     { "tx_used_desc" },
>> +};
>> +
>> +struct sun8i_emac_stats {
>> +     u64 rx_payload_error;
>> +     u64 rx_crc_error;
>> +     u64 rx_phy_error;
>> +     u64 rx_length_error;
>> +     u64 rx_col_error;
>> +     u64 rx_header_error;
>> +     u64 rx_overflow_error;
>> +     u64 rx_saf_fail;
>> +     u64 rx_daf_fail;
>> +     u64 rx_buf_error;
>> +
>> +     u64 tx_stop_queue;
>> +     u64 rx_dma_ua;
>> +     u64 rx_dma_stop;
>> +     u64 tx_dma_ua;
>> +     u64 tx_dma_stop;
>> +     u64 rx_hw_csum;
>> +     u64 tx_hw_csum;
>> +
>> +     u64 rx_early_int;
>> +     u64 tx_early_int;
>> +     u64 tx_underflow_int;
>> +     u64 tx_used_desc;
>> +};
>> +
>> +/* The datasheet said that each descriptor can transfers up to 4096byte=
s
>> + * But latter, a register documentation reduce that value to 2048
>> + * Anyway using 2048 cause strange behaviours and even BSP driver use 2=
047
>> + */
>> +#define DESC_BUF_MAX 2044
>> +#if (DESC_BUF_MAX < (ETH_FRAME_LEN + 4))
>> +#error "DESC_BUF_MAX must be set at minimum to ETH_FRAME_LEN + 4"
>> +#endif
>> +
>> +/* MAGIC value for knowing if a descriptor is available or not */
>> +#define DCLEAN (BIT(16) | BIT(14) | BIT(12) | BIT(10) | BIT(9))
>> +
>> +/* Structure of DMA descriptor used by the hardware  */
>> +struct dma_desc {
>> +     u32 status; /* status of the descriptor */
>> +     u32 st; /* Information on the frame */
>> +     u32 buf_addr; /* physical address of the frame data */
>> +     u32 next; /* physical address of next dma_desc */
>> +} __packed __aligned(4);
>
> I don't think we need this alignment attribute here:
> 1) The structure will be 4-byte aligned anyway, because the first member
> is naturally 4 bytes aligned.
> 2) The alignment requirement is on the physical DMA side. I don't see
> how the compiler should be able to guarantee this. So technically you
> have to tell the DMA allocation code about your alignment requirement.
> But due to 1), I think this is a moot discussion.
>
>> +
>> +/* Benched on OPIPC with 100M, setting more than 256 does not give any
>> + * perf boost
>> + */
>> +static int nbdesc_tx =3D 256;
>> +module_param(nbdesc_tx, int, S_IRUGO | S_IWUSR);
>> +MODULE_PARM_DESC(nbdesc_tx, "Number of descriptors in the TX list");
>> +static int nbdesc_rx =3D 128;
>> +module_param(nbdesc_rx, int, S_IRUGO | S_IWUSR);
>> +MODULE_PARM_DESC(nbdesc_rx, "Number of descriptors in the RX list");
>> +
>> +struct sun8i_emac_priv {
>> +     void __iomem *base;
>> +     void __iomem *syscon;
>> +     int irq;
>> +     struct device *dev;
>> +     struct net_device *ndev;
>> +     struct mii_bus *mdio;
>> +     spinlock_t lock;/* for adjust_link */
>> +     spinlock_t tx_lock;/* control the access of transmit descriptors *=
/
>> +     int duplex;
>> +     int speed;
>> +     int link;
>> +     int phy_interface;
>> +     enum emac_variant variant;
>> +     struct device_node *phy_node;
>> +     struct clk *ahb_clk;
>> +     struct clk *ephy_clk;
>> +     bool use_internal_phy;
>> +
>> +     struct reset_control *rst;
>> +     struct reset_control *rst_ephy;
>> +
>> +     struct dma_desc *dd_rx __aligned(4);
>> +     dma_addr_t dd_rx_phy __aligned(4);
>> +     struct dma_desc *dd_tx __aligned(4);
>> +     dma_addr_t dd_tx_phy __aligned(4);
>
> Same here. The alignment attribute is pointless (the data types are at
> least 4 bytes aligned anyway) and also wrong for the pointers (the
> virtual address of the pointer can be anything (and will be 4 or 8-bytes
> aligned anyway), but the memory its points to should be aligned.
>
> So I think it's safe to remove them.
>
>> +     struct sk_buff **rx_sk;
>> +     struct sk_buff **tx_sk;
>> +     int *tx_map;
>> +
>> +     int tx_slot;
>> +     int tx_dirty;
>> +     int rx_dirty;
>> +     struct sun8i_emac_stats estats;
>> +     u32 msg_enable;
>> +     int flow_ctrl;
>> +     int pause;
>> +};
>> +
>> +static void rb_inc(int *p, const int max)
>> +{
>> +     (*p)++;
>> +     if (*p >=3D max)
>> +             *p =3D 0;
>> +}
>> +
>> +/* Return the number of contiguous free descriptors
>> + * starting from tx_slot
>> + */
>> +static int rb_tx_numfreedesc(struct net_device *ndev)
>> +{
>> +     struct sun8i_emac_priv *priv =3D netdev_priv(ndev);
>> +
>> +     if (priv->tx_slot < priv->tx_dirty)
>> +             return priv->tx_dirty - priv->tx_slot;
>> +
>> +     return (nbdesc_tx - priv->tx_slot) + priv->tx_dirty;
>> +}
>> +
>> +/* Allocate a skb in a DMA descriptor
>> + *
>> + * @i index of slot to fill
>> +*/
>> +static int sun8i_emac_rx_sk(struct net_device *ndev, int i)
>> +{
>> +     struct sun8i_emac_priv *priv =3D netdev_priv(ndev);
>> +     struct dma_desc *ddesc;
>> +     struct sk_buff *sk;
>> +
>> +     ddesc =3D priv->dd_rx + i;
>> +
>> +     ddesc->st =3D 0;
>> +
>> +     sk =3D netdev_alloc_skb_ip_align(ndev, DESC_BUF_MAX);
>> +     if (!sk)
>> +             return -ENOMEM;
>> +
>> +     /* should not happen */
>> +     if (unlikely(priv->rx_sk[i]))
>> +             dev_warn(priv->dev, "BUG: Leaking a skbuff\n");
>> +
>> +     priv->rx_sk[i] =3D sk;
>> +
>> +     ddesc->buf_addr =3D dma_map_single(priv->dev, sk->data,
>> +                                      DESC_BUF_MAX, DMA_FROM_DEVICE);
>> +     if (dma_mapping_error(priv->dev, ddesc->buf_addr)) {
>> +             dev_err(priv->dev, "ERROR: Cannot dma_map RX buffer\n");
>> +             dev_kfree_skb(sk);
>> +             return -EFAULT;
>> +     }
>
> DMA-API.txt tells me that we have to make sure this memory region is
> cache-line aligned, also ends on a cache line boundary, to ensure coheren=
cy.
> Do we need any special calls here to make this happen? I am not an DMA
> expert, so don't know of the usual way to ensure this.
>
> Or shall we use dma_malloc_coherent (or even a DMA pool) to allocate DMA
> memory with the proper alignment requirements and then put the skb's in
> there?
>
>> +     ddesc->st |=3D DESC_BUF_MAX;
>> +     ddesc->status =3D BIT(31);
>> +
>> +     return 0;
>> +}
>
> ....
>
>> +
>> +
>> +     priv->rx_sk =3D kcalloc(nbdesc_rx, sizeof(struct sk_buff *), GFP_K=
ERNEL);
>> +     if (!priv->rx_sk) {
>> +             err =3D -ENOMEM;
>> +             goto rx_sk_error;
>> +     }
>> +     priv->tx_sk =3D kcalloc(nbdesc_tx, sizeof(struct sk_buff *), GFP_K=
ERNEL);
>> +     if (!priv->tx_sk) {
>> +             err =3D -ENOMEM;
>> +             goto tx_sk_error;
>> +     }
>> +     priv->tx_map =3D kcalloc(nbdesc_tx, sizeof(int), GFP_KERNEL);
>> +     if (!priv->tx_map) {
>> +             err =3D -ENOMEM;
>> +             goto tx_map_error;
>> +     }
>> +
>> +     priv->dd_rx =3D dma_alloc_coherent(priv->dev,
>> +                     nbdesc_rx * sizeof(struct dma_desc),
>> +                     &priv->dd_rx_phy,
>> +                     GFP_KERNEL);
>
> You need to be sure here to allocate 32-bit DMA memory only, since the
> hardware holds only 32 bits worth of addresses. If I am not mistaken,
> the following snippet (preferrably in the probe function below) should
> take care of this:
>
>         if (dma_set_mask_and_coherent(&priv->dev, DMA_BIT_MASK(32))) {
>                 dev_err(&priv->dev, "No suitable DMA available\n");
>                 return -ENOMEM;
>         }
>
> This isn't an issue for the SoCs we know of (they have a 32-bit bus
> anyway), but future SoCs could support more memory (the A80 does
> already!), so you have to allocate it from the low 4GB. This is a
> limitation of that particular _device_ (and not the platform), since it
> does the DMA itself and this engine is limited to 32-bit physical address=
es.
>
>> +     if (!priv->dd_rx) {
>> +             dev_err(priv->dev, "ERROR: cannot DMA RX");
>> +             err =3D -ENOMEM;
>> +             goto dma_rx_error;
>> +     }
>
> ....
>
>> +
>> +static const struct of_device_id sun8i_emac_of_match_table[] =3D {
>> +     { .compatible =3D "allwinner,sun8i-a83t-emac",
>> +       .data =3D (void *)A83T_EMAC },
>> +     { .compatible =3D "allwinner,sun8i-h3-emac",
>> +       .data =3D (void *)H3_EMAC },
>> +     { .compatible =3D "allwinner,sun50i-a64-emac",
>> +       .data =3D (void *)A64_EMAC },
>> +     {}
>> +};
>
> I am not sure this is the proper way to model the different variants of
> the device. I see two differing features here:
> 1) the H3 has an internal PHY
> 2) the A83T does not support RMII

The compatible string encodes the different "EMAC + glue layer" variants.
The underlying MAC hardware may be the same, but the exposed interface
and addons are slightly different.

> So wouldn't it be wiser to put those two options as properties into the
> DT node? This way any future EMAC version could pick the matching
> features and we wouldn't need to add a new compatible string for each
> and every new SoC which carries this device and thus hardcode it's
> properties in this driver.

If the new device carries a version that is completely the same as one
of the supported ones, you just use that compatible. The SoC name here
need not be the same as the SoC you are adding support for. It is just
the first SoC that we've seen this type of hardware on.


Regards
ChenYu

>
> Cheers,
> Andre.
>
>> +MODULE_DEVICE_TABLE(of, sun8i_emac_of_match_table);
>> +
>> +static struct platform_driver sun8i_emac_driver =3D {
>> +     .probe          =3D sun8i_emac_probe,
>> +     .remove         =3D sun8i_emac_remove,
>> +     .driver         =3D {
>> +             .name           =3D "sun8i-emac",
>> +             .of_match_table =3D sun8i_emac_of_match_table,
>> +     },
>> +};
>> +
>> +module_platform_driver(sun8i_emac_driver);
>> +
>> +MODULE_DESCRIPTION("sun8i Ethernet driver");
>> +MODULE_LICENSE("GPL");
>> +MODULE_AUTHOR("LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org");
>>
>

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
