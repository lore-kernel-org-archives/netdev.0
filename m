From: Jon Mason <jon.mason@exar.com>
Subject: Re: [PATCH v2] net: Fix too optimistic NETIF_F_HW_CSUM features
Date: Wed, 1 Dec 2010 18:44:57 -0600
Message-ID: <20101202004457.GE7200@exar.com>
References: <20101130142352.3936.51663.stgit@rechot.qmqm.pl>
 <20101130163057.29978.92721.stgit@rechot.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Gross <jesse@nicira.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>
To: =?utf-8?Q?Micha=C5=82Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.exar.com ([204.154.183.83]:57067 "EHLO smtp1.exar.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751660Ab0LBApA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 19:45:00 -0500
Content-Disposition: inline
In-Reply-To: <20101130163057.29978.92721.stgit@rechot.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 08:38:00AM -0800, Micha=C5=82Miros=C5=82aw wrot=
e:
> NETIF_F_HW_CSUM is a superset of NETIF_F_IP_CSUM+NETIF_F_IPV6_CSUM, b=
ut
> some drivers miss the difference. Fix this and also fix UFO dependenc=
y
> on checksumming offload as it makes the same mistake in assumptions.
>
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

The vxge sections look sane to me.

Acked-by: Jon Mason <jon.mason@exar.com>
> ---
>
> Changes from v1:
> - fixed compilation of jme driver
> - enable vxge support for IPv6 checksum
> ---
>  drivers/net/vxge/vxge-ethtool.c |    2 +-
>  drivers/net/vxge/vxge-main.c    |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.=
c
> index 102567e..2754280 100644
> --- a/drivers/net/benet/be_main.c
> +++ b/drivers/net/benet/be_main.c
> @@ -2583,10 +2583,12 @@ static void be_netdev_init(struct net_device =
*netdev)
>       int i;
>
>       netdev->features |=3D NETIF_F_SG | NETIF_F_HW_VLAN_RX | NETIF_F=
_TSO |
> -             NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER | NETIF_F_H=
W_CSUM |
> +             NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER |
> +             NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>               NETIF_F_GRO | NETIF_F_TSO6;
>
> -     netdev->vlan_features |=3D NETIF_F_SG | NETIF_F_TSO | NETIF_F_H=
W_CSUM;
> +     netdev->vlan_features |=3D NETIF_F_SG | NETIF_F_TSO |
> +             NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
>
>       if (lancer_chip(adapter))
>               netdev->vlan_features |=3D NETIF_F_TSO6;
> diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x=
_main.c
> index f53edfd..40ce95a 100644
> --- a/drivers/net/bnx2x/bnx2x_main.c
> +++ b/drivers/net/bnx2x/bnx2x_main.c
> @@ -8761,7 +8761,7 @@ static int __devinit bnx2x_init_dev(struct pci_=
dev *pdev,
>       dev->netdev_ops =3D &bnx2x_netdev_ops;
>       bnx2x_set_ethtool_ops(dev);
>       dev->features |=3D NETIF_F_SG;
> -     dev->features |=3D NETIF_F_HW_CSUM;
> +     dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
>       if (bp->flags & USING_DAC_FLAG)
>               dev->features |=3D NETIF_F_HIGHDMA;
>       dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
> @@ -8769,7 +8769,7 @@ static int __devinit bnx2x_init_dev(struct pci_=
dev *pdev,
>       dev->features |=3D (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
>
>       dev->vlan_features |=3D NETIF_F_SG;
> -     dev->vlan_features |=3D NETIF_F_HW_CSUM;
> +     dev->vlan_features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
>       if (bp->flags & USING_DAC_FLAG)
>               dev->vlan_features |=3D NETIF_F_HIGHDMA;
>       dev->vlan_features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
> diff --git a/drivers/net/jme.c b/drivers/net/jme.c
> index c57d9a4..2411e72 100644
> --- a/drivers/net/jme.c
> +++ b/drivers/net/jme.c
> @@ -2076,12 +2076,11 @@ jme_change_mtu(struct net_device *netdev, int=
 new_mtu)
>       }
>
>       if (new_mtu > 1900) {
> -             netdev->features &=3D ~(NETIF_F_HW_CSUM |
> -                             NETIF_F_TSO |
> -                             NETIF_F_TSO6);
> +             netdev->features &=3D ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_=
CSUM |
> +                             NETIF_F_TSO | NETIF_F_TSO6);
>       } else {
>               if (test_bit(JME_FLAG_TXCSUM, &jme->flags))
> -                     netdev->features |=3D NETIF_F_HW_CSUM;
> +                     netdev->features |=3D NETIF_F_IP_CSUM | NETIF_F=
_IPV6_CSUM;
>               if (test_bit(JME_FLAG_TSO, &jme->flags))
>                       netdev->features |=3D NETIF_F_TSO | NETIF_F_TSO=
6;
>       }
> @@ -2514,10 +2513,12 @@ jme_set_tx_csum(struct net_device *netdev, u3=
2 on)
>       if (on) {
>               set_bit(JME_FLAG_TXCSUM, &jme->flags);
>               if (netdev->mtu <=3D 1900)
> -                     netdev->features |=3D NETIF_F_HW_CSUM;
> +                     netdev->features |=3D
> +                             NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
>       } else {
>               clear_bit(JME_FLAG_TXCSUM, &jme->flags);
> -             netdev->features &=3D ~NETIF_F_HW_CSUM;
> +             netdev->features &=3D
> +                             ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
>       }
>
>       return 0;
> @@ -2797,7 +2798,8 @@ jme_init_one(struct pci_dev *pdev,
>       netdev->netdev_ops =3D &jme_netdev_ops;
>       netdev->ethtool_ops             =3D &jme_ethtool_ops;
>       netdev->watchdog_timeo          =3D TX_TIMEOUT;
> -     netdev->features                =3D       NETIF_F_HW_CSUM |
> +     netdev->features                =3D       NETIF_F_IP_CSUM |
> +                                             NETIF_F_IPV6_CSUM |
>                                               NETIF_F_SG |
>                                               NETIF_F_TSO |
>                                               NETIF_F_TSO6 |
> diff --git a/drivers/net/pch_gbe/pch_gbe_ethtool.c b/drivers/net/pch_=
gbe/pch_gbe_ethtool.c
> index c8cc32c..c8c873b 100644
> --- a/drivers/net/pch_gbe/pch_gbe_ethtool.c
> +++ b/drivers/net/pch_gbe/pch_gbe_ethtool.c
> @@ -469,18 +469,6 @@ static int pch_gbe_set_rx_csum(struct net_device=
 *netdev, u32 data)
>  }
>
>  /**
> - * pch_gbe_get_tx_csum - Report whether transmit checksums are turne=
d on or off
> - * @netdev:  Network interface device structure
> - * Returns
> - *   true(1):  Checksum On
> - *   false(0): Checksum Off
> - */
> -static u32 pch_gbe_get_tx_csum(struct net_device *netdev)
> -{
> -     return (netdev->features & NETIF_F_HW_CSUM) !=3D 0;
> -}
> -
> -/**
>   * pch_gbe_set_tx_csum - Turn transmit checksums on or off
>   * @netdev: Network interface device structure
>   * @data:   Checksum on[true] or off[false]
> @@ -493,11 +481,7 @@ static int pch_gbe_set_tx_csum(struct net_device=
 *netdev, u32 data)
>       struct pch_gbe_adapter *adapter =3D netdev_priv(netdev);
>
>       adapter->tx_csum =3D data;
> -     if (data)
> -             netdev->features |=3D NETIF_F_HW_CSUM;
> -     else
> -             netdev->features &=3D ~NETIF_F_HW_CSUM;
> -     return 0;
> +     return ethtool_op_set_tx_ipv6_csum(netdev, data);
>  }
>
>  /**
> @@ -572,7 +556,6 @@ static const struct ethtool_ops pch_gbe_ethtool_o=
ps =3D {
>       .set_pauseparam =3D pch_gbe_set_pauseparam,
>       .get_rx_csum =3D pch_gbe_get_rx_csum,
>       .set_rx_csum =3D pch_gbe_set_rx_csum,
> -     .get_tx_csum =3D pch_gbe_get_tx_csum,
>       .set_tx_csum =3D pch_gbe_set_tx_csum,
>       .get_strings =3D pch_gbe_get_strings,
>       .get_ethtool_stats =3D pch_gbe_get_ethtool_stats,
> diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe=
/pch_gbe_main.c
> index afb7506..58e7903 100644
> --- a/drivers/net/pch_gbe/pch_gbe_main.c
> +++ b/drivers/net/pch_gbe/pch_gbe_main.c
> @@ -2319,7 +2319,7 @@ static int pch_gbe_probe(struct pci_dev *pdev,
>       netdev->watchdog_timeo =3D PCH_GBE_WATCHDOG_PERIOD;
>       netif_napi_add(netdev, &adapter->napi,
>                      pch_gbe_napi_poll, PCH_GBE_RX_WEIGHT);
> -     netdev->features =3D NETIF_F_HW_CSUM | NETIF_F_GRO;
> +     netdev->features =3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETI=
=46_F_GRO;
>       pch_gbe_set_ethtool_ops(netdev);
>
>       pch_gbe_mac_reset_hw(&adapter->hw);
> @@ -2358,9 +2358,9 @@ static int pch_gbe_probe(struct pci_dev *pdev,
>       pch_gbe_check_options(adapter);
>
>       if (adapter->tx_csum)
> -             netdev->features |=3D NETIF_F_HW_CSUM;
> +             netdev->features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CS=
UM;
>       else
> -             netdev->features &=3D ~NETIF_F_HW_CSUM;
> +             netdev->features &=3D ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_=
CSUM);
>
>       /* initialize the wol settings based on the eeprom settings */
>       adapter->wake_up_evt =3D PCH_GBE_WL_INIT_SETTING;
> diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
> index 417adf3..76290a8 100644
> --- a/drivers/net/sc92031.c
> +++ b/drivers/net/sc92031.c
> @@ -1449,7 +1449,8 @@ static int __devinit sc92031_probe(struct pci_d=
ev *pdev,
>       dev->irq =3D pdev->irq;
>
>       /* faked with skb_copy_and_csum_dev */
> -     dev->features =3D NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDM=
A;
> +     dev->features =3D NETIF_F_SG | NETIF_F_HIGHDMA |
> +             NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
>
>       dev->netdev_ops         =3D &sc92031_netdev_ops;
>       dev->watchdog_timeo     =3D TX_TIMEOUT;
> diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac=
/stmmac_ethtool.c
> index f2695fd..fd719ed 100644
> --- a/drivers/net/stmmac/stmmac_ethtool.c
> +++ b/drivers/net/stmmac/stmmac_ethtool.c
> @@ -197,16 +197,6 @@ static void stmmac_ethtool_gregs(struct net_devi=
ce *dev,
>       }
>  }
>
> -static int stmmac_ethtool_set_tx_csum(struct net_device *netdev, u32=
 data)
> -{
> -     if (data)
> -             netdev->features |=3D NETIF_F_HW_CSUM;
> -     else
> -             netdev->features &=3D ~NETIF_F_HW_CSUM;
> -
> -     return 0;
> -}
> -
>  static u32 stmmac_ethtool_get_rx_csum(struct net_device *dev)
>  {
>       struct stmmac_priv *priv =3D netdev_priv(dev);
> @@ -370,7 +360,7 @@ static struct ethtool_ops stmmac_ethtool_ops =3D =
{
>       .get_link =3D ethtool_op_get_link,
>       .get_rx_csum =3D stmmac_ethtool_get_rx_csum,
>       .get_tx_csum =3D ethtool_op_get_tx_csum,
> -     .set_tx_csum =3D stmmac_ethtool_set_tx_csum,
> +     .set_tx_csum =3D ethtool_op_set_tx_ipv6_csum,
>       .get_sg =3D ethtool_op_get_sg,
>       .set_sg =3D ethtool_op_set_sg,
>       .get_pauseparam =3D stmmac_get_pauseparam,
> diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/st=
mmac_main.c
> index 730a6fd..bfc2d12 100644
> --- a/drivers/net/stmmac/stmmac_main.c
> +++ b/drivers/net/stmmac/stmmac_main.c
> @@ -1494,7 +1494,8 @@ static int stmmac_probe(struct net_device *dev)
>       dev->netdev_ops =3D &stmmac_netdev_ops;
>       stmmac_set_ethtool_ops(dev);
>
> -     dev->features |=3D (NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGH=
DMA);
> +     dev->features |=3D NETIF_F_SG | NETIF_F_HIGHDMA |
> +             NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
>       dev->watchdog_timeo =3D msecs_to_jiffies(watchdog);
>  #ifdef STMMAC_VLAN_TAG_USED
>       /* Both mac100 and gmac support receive VLAN tag detection */
> @@ -1525,7 +1526,7 @@ static int stmmac_probe(struct net_device *dev)
>
>       DBG(probe, DEBUG, "%s: Scatter/Gather: %s - HW checksums: %s\n"=
,
>           dev->name, (dev->features & NETIF_F_SG) ? "on" : "off",
> -         (dev->features & NETIF_F_HW_CSUM) ? "on" : "off");
> +         (dev->features & NETIF_F_IP_CSUM) ? "on" : "off");
>
>       spin_lock_init(&priv->lock);
>
> diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge/vxge-=
ethtool.c
> index bc9bd10..1dd3a21 100644
> --- a/drivers/net/vxge/vxge-ethtool.c
> +++ b/drivers/net/vxge/vxge-ethtool.c
> @@ -1177,7 +1177,7 @@ static const struct ethtool_ops vxge_ethtool_op=
s =3D {
>       .get_rx_csum            =3D vxge_get_rx_csum,
>       .set_rx_csum            =3D vxge_set_rx_csum,
>       .get_tx_csum            =3D ethtool_op_get_tx_csum,
> -     .set_tx_csum            =3D ethtool_op_set_tx_hw_csum,
> +     .set_tx_csum            =3D ethtool_op_set_tx_ipv6_csum,
>       .get_sg                 =3D ethtool_op_get_sg,
>       .set_sg                 =3D ethtool_op_set_sg,
>       .get_tso                =3D ethtool_op_get_tso,
> diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-mai=
n.c
> index a21dae1..d339f5b 100644
> --- a/drivers/net/vxge/vxge-main.c
> +++ b/drivers/net/vxge/vxge-main.c
> @@ -3368,7 +3368,7 @@ static int __devinit vxge_device_register(struc=
t __vxge_hw_device *hldev,
>
>       ndev->features |=3D NETIF_F_SG;
>
> -     ndev->features |=3D NETIF_F_HW_CSUM;
> +     ndev->features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
>       vxge_debug_init(vxge_hw_device_trace_level_get(hldev),
>               "%s : checksuming enabled", __func__);
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 3259d2c..622f85a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5041,10 +5041,13 @@ unsigned long netdev_fix_features(unsigned lo=
ng features, const char *name)
>       }
>
>       if (features & NETIF_F_UFO) {
> -             if (!(features & NETIF_F_GEN_CSUM)) {
> +             /* maybe split UFO into V4 and V6? */
> +             if (!((features & NETIF_F_GEN_CSUM) ||
> +                 (features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
> +                         =3D=3D (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))=
) {
>                       if (name)
>                               printk(KERN_ERR "%s: Dropping NETIF_F_U=
=46O "
> -                                    "since no NETIF_F_HW_CSUM featur=
e.\n",
> +                                    "since no checksum offload featu=
res.\n",
>                                      name);
>                       features &=3D ~NETIF_F_UFO;
>               }
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 956a9f4..d5bc2881 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1171,7 +1171,9 @@ static int ethtool_set_ufo(struct net_device *d=
ev, char __user *useraddr)
>               return -EFAULT;
>       if (edata.data && !(dev->features & NETIF_F_SG))
>               return -EINVAL;
> -     if (edata.data && !(dev->features & NETIF_F_HW_CSUM))
> +     if (edata.data && !((dev->features & NETIF_F_GEN_CSUM) ||
> +             (dev->features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
> +                     =3D=3D (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM)))
>               return -EINVAL;
>       return dev->ethtool_ops->set_ufo(dev, edata.data);
>  }
>

The information and any attached documents contained in this message
may be confidential and/or legally privileged.  The message is
intended solely for the addressee(s).  If you are not the intended
recipient, you are hereby notified that any use, dissemination, or
reproduction is strictly prohibited and may be unlawful.  If you are
not the intended recipient, please contact the sender immediately by
return e-mail and destroy all copies of the original message.
