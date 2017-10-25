From: Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH net-next v3 2/2] net: ethernet: socionext: add AVE
 ethernet driver
Date: Wed, 25 Oct 2017 11:52:45 +0900
Message-ID: <CAK7LNAQZn046gGUkQUV3j_v=Te+Hawqy_6R3+Yff_F0gwRs02Q@mail.gmail.com>
References: <1508893679-11727-1-git-send-email-hayashi.kunihiko@socionext.com> <1508893679-11727-3-git-send-email-hayashi.kunihiko@socionext.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Masami Hiramatsu <masami.hiramatsu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1508893679-11727-3-git-send-email-hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2017-10-25 10:07 GMT+09:00 Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>:

> +
> +/* Descriptor Control Register Group */
> +#define AVE_DESCC      0x300   /* Descriptor Control */
> +#define AVE_TXDC       0x304   /* TX Descriptor Configuration */
> +#define AVE_RXDC0      0x308   /* RX Descriptor Ring0 Configuration */
> +#define AVE_IIRQC      0x34c   /* Interval IRQ Control */
> +
> +/* Packet Filter Register Group */
> +#define AVE_PKTF_BASE          0x800   /* PF Base Address */
> +#define AVE_PFMBYTE_BASE       0xd00   /* PF Mask Byte Base Address */
> +#define AVE_PFMBIT_BASE                0xe00   /* PF Mask Bit Base Address */
> +#define AVE_PFSEL_BASE         0xf00   /* PF Selector Base Address */
> +#define AVE_PFEN               0xffc   /* Packet Filter Enable */
> +#define AVE_PKTF(ent)          (AVE_PKTF_BASE + (ent) * 0x40)
> +#define AVE_PFMBYTE(ent)       (AVE_PFMBYTE_BASE + (ent) * 8)
> +#define AVE_PFMBIT(ent)                (AVE_PFMBIT_BASE + (ent) * 4)
> +#define AVE_PFSEL(ent)         (AVE_PFSEL_BASE + (ent) * 4)
> +
> +/* 64bit descriptor memory */
> +#define AVE_DESC_SIZE_64       12      /* Descriptor Size */
> +
> +#define AVE_TXDM_64            0x1000  /* Tx Descriptor Memory */
> +#define AVE_RXDM_64            0x1c00  /* Rx Descriptor Memory */
> +
> +#define AVE_TXDM_SIZE_64       0x0ba0  /* Tx Descriptor Memory Size 3KB */
> +#define AVE_RXDM_SIZE_64       0x6000  /* Rx Descriptor Memory Size 24KB */
> +
> +/* 32bit descriptor memory */
> +#define AVE_DESC_SIZE_32       8       /* Descriptor Size */
> +
> +#define AVE_TXDM_32            0x1000  /* Tx Descriptor Memory */
> +#define AVE_RXDM_32            0x1800  /* Rx Descriptor Memory */
> +
> +#define AVE_TXDM_SIZE_32       0x07c0  /* Tx Descriptor Memory Size 2KB */
> +#define AVE_RXDM_SIZE_32       0x4000  /* Rx Descriptor Memory Size 16KB */
> +
> +/* RMII Bridge Register Group */
> +#define AVE_RSTCTRL            0x8028  /* Reset control */
> +#define AVE_RSTCTRL_RMIIRST    BIT(16)
> +#define AVE_LINKSEL            0x8034  /* Link speed setting */
> +#define AVE_LINKSEL_100M       BIT(0)
> +
> +/* AVE_GRR */
> +#define AVE_GRR_RXFFR          BIT(5)  /* Reset RxFIFO */
> +#define AVE_GRR_PHYRST         BIT(4)  /* Reset external PHY */
> +#define AVE_GRR_GRST           BIT(0)  /* Reset all MAC */
> +
> +/* AVE_GISR (common with GIMR) */
> +#define AVE_GI_PHY             BIT(24) /* PHY interrupt */
> +#define AVE_GI_TX              BIT(16) /* Tx complete */
> +#define AVE_GI_RXERR           BIT(8)  /* Receive frame more than max size */
> +#define AVE_GI_RXOVF           BIT(7)  /* Overflow at the RxFIFO */
> +#define AVE_GI_RXDROP          BIT(6)  /* Drop packet */
> +#define AVE_GI_RXIINT          BIT(5)  /* Interval interrupt */
> +
> +/* AVE_TXCR */
> +#define AVE_TXCR_FLOCTR                BIT(18) /* Flow control */
> +#define AVE_TXCR_TXSPD_1G      BIT(17)
> +#define AVE_TXCR_TXSPD_100     BIT(16)
> +
> +/* AVE_RXCR */
> +#define AVE_RXCR_RXEN          BIT(30) /* Rx enable */
> +#define AVE_RXCR_FDUPEN                BIT(22) /* Interface mode */
> +#define AVE_RXCR_FLOCTR                BIT(21) /* Flow control */
> +#define AVE_RXCR_AFEN          BIT(19) /* MAC address filter */
> +#define AVE_RXCR_DRPEN         BIT(18) /* Drop pause frame */
> +#define AVE_RXCR_MPSIZ_MASK    GENMASK(10, 0)
> +
> +/* AVE_MDIOCTR */
> +#define AVE_MDIOCTR_RREQ       BIT(3)  /* Read request */
> +#define AVE_MDIOCTR_WREQ       BIT(2)  /* Write request */


BIT() is descending.



> +/* AVE_MDIOSR */
> +#define AVE_MDIOSR_STS         BIT(0)  /* access status */
> +
> +/* AVE_DESCC */
> +#define AVE_DESCC_TD           BIT(0)  /* Enable Tx descriptor */
> +#define AVE_DESCC_RDSTP                BIT(4)  /* Pause Rx descriptor */
> +#define AVE_DESCC_RD0          BIT(8)  /* Enable Rx descriptor Ring0 */
> +#define AVE_DESCC_STATUS_MASK  GENMASK(31, 16)


BIT() is ascending.

Please be consistent.






> +
> +static void ave_wdesc_addr(struct net_device *ndev, enum desc_id id,
> +                          int entry, dma_addr_t paddr)
> +{
> +       struct ave_private *priv = netdev_priv(ndev);
> +
> +       ave_wdesc(ndev, id, entry, AVE_DESC_OFS_ADDRL, lower_32_bits(paddr));
> +       if (IS_DESC_64BIT(priv))
> +               ave_wdesc(ndev, id,
> +                         entry, AVE_DESC_OFS_ADDRU, upper_32_bits(paddr));
> +       else if ((u64)paddr > (u64)U32_MAX)
> +               netdev_warn(ndev, "DMA address exceeds the address space\n");
> +}

Yuk!
Why don't you use dma_set_mask() instead of this?




> +
> +static int ave_mdio_busywait(struct net_device *ndev)
> +{
> +       int ret = 0, loop = 100;
> +       u32 mdiosr;
> +
> +       /* wait until completion */
> +       while (--loop) {
> +               mdiosr = ave_r32(ndev, AVE_MDIOSR);
> +               if (!(mdiosr & AVE_MDIOSR_STS))
> +                       break;
> +
> +               usleep_range(10, 20);
> +       }
> +
> +       if (!loop) {
> +               netdev_err(ndev,
> +                          "failed to read from MDIO (status:0x%08x)\n",
> +                          mdiosr);
> +               ret = -ETIMEDOUT;
> +       }
> +
> +       return ret;
> +}


The whole of this function can be replaced with
readl_poll_timeout() unless you stick to ave_r32.


I do not understand why you are such a big fan of
driver-specific accessors like ave_r32/ave_w32.



> +static int ave_mdiobus_read(struct mii_bus *bus, int phyid, int regnum)
> +{
> +       struct net_device *ndev = bus->priv;
> +       u32 mdioctl;
> +       int ret;
> +
> +       /* write address */
> +       ave_w32(ndev, AVE_MDIOAR, (phyid << 8) | regnum);
> +
> +       /* read request */
> +       mdioctl = ave_r32(ndev, AVE_MDIOCTR);
> +       ave_w32(ndev, AVE_MDIOCTR,
> +               (mdioctl | AVE_MDIOCTR_RREQ) & ~AVE_MDIOCTR_WREQ);
> +
> +       ret = ave_mdio_busywait(ndev);
> +       if (ret) {
> +               netdev_err(ndev, "phy-%d reg-%x read failed\n",
> +                          phyid, regnum);
> +               return ret;
> +       }
> +
> +       return ave_r32(ndev, AVE_MDIORDR) & GENMASK(15, 0);
> +}
> +
> +static int ave_mdiobus_write(struct mii_bus *bus,
> +                            int phyid, int regnum, u16 val)
> +{
> +       struct net_device *ndev = bus->priv;
> +       u32 mdioctl;
> +       int ret;
> +
> +       /* write address */
> +       ave_w32(ndev, AVE_MDIOAR, (phyid << 8) | regnum);
> +
> +       /* write data */
> +       ave_w32(ndev, AVE_MDIOWDR, val);
> +
> +       /* write request */
> +       mdioctl = ave_r32(ndev, AVE_MDIOCTR);
> +       ave_w32(ndev, AVE_MDIOCTR,
> +               (mdioctl | AVE_MDIOCTR_WREQ) & ~AVE_MDIOCTR_RREQ);
> +
> +       ret = ave_mdio_busywait(ndev);
> +       if (ret)
> +               netdev_err(ndev, "phy-%d reg-%x write failed\n",
> +                          phyid, regnum);
> +
> +       return ret;
> +}
> +
> +static dma_addr_t ave_dma_map(struct net_device *ndev, struct ave_desc *desc,
> +                             void *ptr, size_t len,
> +                             enum dma_data_direction dir)
> +{
> +       dma_addr_t paddr;
> +
> +       paddr = dma_map_single(ndev->dev.parent, ptr, len, dir);
> +       if (unlikely(dma_mapping_error(ndev->dev.parent, paddr))) {
> +               paddr = (dma_addr_t)-ENOMEM;

Yuk!

Re-write the code.


> +       } else {
> +               desc->skbs_dma = paddr;
> +               desc->skbs_dmalen = len;
> +       }
> +
> +       return paddr;
> +}


-- 
Best Regards
Masahiro Yamada
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
