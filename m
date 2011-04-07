From: roprabhu <roprabhu@cisco.com>
Subject: Re: [PATCH] net: enic: convert to hw_features
Date: Thu, 07 Apr 2011 12:52:45 -0700
Message-ID: <C9C3641D.23F23%roprabhu@cisco.com>
References: <20110407124348.BB13A138ED@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christian Benvenuti <benve@cisco.com>,
	Vasanthy Kolluri <vkolluri@cisco.com>,
	David Wang <dwang2@cisco.com>
To: =?ISO-8859-2?B?TWljaGGz?= =?ISO-8859-2?B?IE1pcm9zs2F3?=
	<mirq-linux@rere.qmqm.pl>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:41081 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756757Ab1DGTwq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 15:52:46 -0400
In-Reply-To: <20110407124348.BB13A138ED@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks michal.

One small comment below,

On 4/7/11 5:43 AM, "Micha=B3 Miros=B3aw" <mirq-linux@rere.qmqm.pl> wrot=
e:

> As the driver uses GRO and not LRO, LRO settings are ignored anyway
> and are removed here to avoid confusion.
>=20
> Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> ---
>  drivers/net/enic/enic.h      |    1 -
>  drivers/net/enic/enic_main.c |   74 ++++----------------------------=
---------
>  drivers/net/enic/enic_res.c  |    4 +-
>  3 files changed, 10 insertions(+), 69 deletions(-)
>=20
> diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
> index 178b94d..38b351c 100644
> --- a/drivers/net/enic/enic.h
> +++ b/drivers/net/enic/enic.h
> @@ -84,7 +84,6 @@ struct enic {
> unsigned int flags;
> unsigned int mc_count;
> unsigned int uc_count;
> - int csum_rx_enabled;
> u32 port_mtu;
> u32 rx_coalesce_usecs;
> u32 tx_coalesce_usecs;
> diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_mai=
n.c
> index 9a3a027..b224551 100644
> --- a/drivers/net/enic/enic_main.c
> +++ b/drivers/net/enic/enic_main.c
> @@ -251,56 +251,6 @@ static void enic_get_ethtool_stats(struct net_de=
vice
> *netdev,
> *(data++) =3D ((u64 *)&vstats->rx)[enic_rx_stats[i].offset];
>  }
> =20
> -static u32 enic_get_rx_csum(struct net_device *netdev)
> -{
> - struct enic *enic =3D netdev_priv(netdev);
> - return enic->csum_rx_enabled;
> -}
> -
> -static int enic_set_rx_csum(struct net_device *netdev, u32 data)
> -{
> - struct enic *enic =3D netdev_priv(netdev);
> -
> - if (data && !ENIC_SETTING(enic, RXCSUM))
> -  return -EINVAL;
> -
> - enic->csum_rx_enabled =3D !!data;
> -
> - return 0;
> -}
> -
> -static int enic_set_tx_csum(struct net_device *netdev, u32 data)
> -{
> - struct enic *enic =3D netdev_priv(netdev);
> -
> - if (data && !ENIC_SETTING(enic, TXCSUM))
> -  return -EINVAL;
> -
> - if (data)
> -  netdev->features |=3D NETIF_F_HW_CSUM;
> - else
> -  netdev->features &=3D ~NETIF_F_HW_CSUM;
> -
> - return 0;
> -}
> -
> -static int enic_set_tso(struct net_device *netdev, u32 data)
> -{
> - struct enic *enic =3D netdev_priv(netdev);
> -
> - if (data && !ENIC_SETTING(enic, TSO))
> -  return -EINVAL;
> -
> - if (data)
> -  netdev->features |=3D
> -   NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN;
> - else
> -  netdev->features &=3D
> -   ~(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN);
> -
> - return 0;
> -}
> -
>  static u32 enic_get_msglevel(struct net_device *netdev)
>  {
> struct enic *enic =3D netdev_priv(netdev);
> @@ -388,17 +338,8 @@ static const struct ethtool_ops enic_ethtool_ops=
 =3D {
> .get_strings =3D enic_get_strings,
> .get_sset_count =3D enic_get_sset_count,
> .get_ethtool_stats =3D enic_get_ethtool_stats,
> - .get_rx_csum =3D enic_get_rx_csum,
> - .set_rx_csum =3D enic_set_rx_csum,
> - .get_tx_csum =3D ethtool_op_get_tx_csum,
> - .set_tx_csum =3D enic_set_tx_csum,
> - .get_sg =3D ethtool_op_get_sg,
> - .set_sg =3D ethtool_op_set_sg,
> - .get_tso =3D ethtool_op_get_tso,
> - .set_tso =3D enic_set_tso,
> .get_coalesce =3D enic_get_coalesce,
> .set_coalesce =3D enic_set_coalesce,
> - .get_flags =3D ethtool_op_get_flags,
>  };
> =20
>  static void enic_free_wq_buf(struct vnic_wq *wq, struct vnic_wq_buf =
*buf)
> @@ -1309,7 +1250,7 @@ static void enic_rq_indicate_buf(struct vnic_rq=
 *rq,
> skb_put(skb, bytes_written);
> skb->protocol =3D eth_type_trans(skb, netdev);
> =20
> -  if (enic->csum_rx_enabled && !csum_not_calc) {
> +  if ((netdev->features & NETIF_F_RXCSUM) && !csum_not_calc) {
> skb->csum =3D htons(checksum);
> skb->ip_summed =3D CHECKSUM_COMPLETE;
> }
> @@ -2438,17 +2379,18 @@ static int __devinit enic_probe(struct pci_de=
v *pdev,
> dev_info(dev, "loopback tag=3D0x%04x\n", enic->loop_tag);
> }
> if (ENIC_SETTING(enic, TXCSUM))
> -  netdev->features |=3D NETIF_F_SG | NETIF_F_HW_CSUM;
> +  netdev->hw_features |=3D NETIF_F_SG | NETIF_F_HW_CSUM;
> if (ENIC_SETTING(enic, TSO))
> -  netdev->features |=3D NETIF_F_TSO |
> +  netdev->hw_features |=3D NETIF_F_TSO |
> NETIF_F_TSO6 | NETIF_F_TSO_ECN;
> - if (ENIC_SETTING(enic, LRO))
> -  netdev->features |=3D NETIF_F_GRO;
> + if (ENIC_SETTING(enic, RXCSUM))
> +  netdev->hw_features |=3D NETIF_F_RXCSUM;
> +
> + netdev->features |=3D netdev->hw_features;
> +
> if (using_dac)
> netdev->features |=3D NETIF_F_HIGHDMA;
> =20
> - enic->csum_rx_enabled =3D ENIC_SETTING(enic, RXCSUM);
> -
> err =3D register_netdev(netdev);
> if (err) {
> dev_err(dev, "Cannot register net device, aborting\n");
> diff --git a/drivers/net/enic/enic_res.c b/drivers/net/enic/enic_res.=
c
> index f111a37..6e5c635 100644
> --- a/drivers/net/enic/enic_res.c
> +++ b/drivers/net/enic/enic_res.c
> @@ -98,9 +98,9 @@ int enic_get_vnic_config(struct enic *enic)
> "vNIC MAC addr %pM wq/rq %d/%d mtu %d\n",
> enic->mac_addr, c->wq_desc_count, c->rq_desc_count, c->mtu);
> dev_info(enic_get_dev(enic), "vNIC csum tx/rx %d/%d "
> -  "tso/lro %d/%d intr timer %d usec rss %d\n",
> +  "tso %d intr timer %d usec rss %d\n",
> ENIC_SETTING(enic, TXCSUM), ENIC_SETTING(enic, RXCSUM),
> -  ENIC_SETTING(enic, TSO), ENIC_SETTING(enic, LRO),
> +  ENIC_SETTING(enic, TSO),
> c->intr_timer_usec, ENIC_SETTING(enic, RSS));
> =20
You are right about the driver using GRO and not LRO by default. But th=
e
config entry from where enic gets this setting is still called LRO for
reasons out of the scope of the driver. Yes, I see that it can lead to
confusion. So, we will need to retain the ENIC_SETTING(enic, LRO) but f=
ix
the name of that setting.  Thanks for pointing this out. We will fix th=
is
and any other changes if required and resubmit.


> return 0;

