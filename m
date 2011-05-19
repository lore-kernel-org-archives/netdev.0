From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next 10/13] tg3: Consolidate all netdev feature assignments
Date: Thu, 19 May 2011 16:15:52 -0700
Message-ID: <BANLkTim7uERxfwd2isfBUbX7WS8-X-Rj9w@mail.gmail.com>
References: <1305843176-32358-11-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:59412 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932723Ab1ESXQQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 19:16:16 -0400
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p4JNG6ab022136
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 16:16:11 -0700
Received: from bwz5 (bwz5.prod.google.com [10.188.26.5])
	by kpbe13.cbf.corp.google.com with ESMTP id p4JNFrKM019825
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 16:15:54 -0700
Received: by bwz5 with SMTP id 5so2906707bwz.6
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 16:15:53 -0700 (PDT)
In-Reply-To: <1305843176-32358-11-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2011 at 3:12 PM, Matt Carlson <mcarlson@broadcom.com> w=
rote:
> This patch consolidates all the netdev feature bit assignments to one
> location.
>
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Reviewed-by: Michael Chan <mchan@broadcom.com>
> ---
> =A0drivers/net/tg3.c | =A0 51 ++++++++++++++++++++++++---------------=
------------
> =A01 files changed, 24 insertions(+), 27 deletions(-)
>
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 09fe067..5bf2ce1 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -13602,19 +13602,6 @@ static int __devinit tg3_get_invariants(stru=
ct tg3 *tp)
> =A0 =A0 =A0 =A0 =A0 =A0tg3_flag(tp, 5750_PLUS))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tg3_flag_set(tp, 5705_PLUS);
>
> - =A0 =A0 =A0 /* 5700 B0 chips do not support checksumming correctly =
due
> - =A0 =A0 =A0 =A0* to hardware bugs.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 if (tp->pci_chip_rev_id !=3D CHIPREV_ID_5700_B0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 features =3D NETIF_F_SG | NETIF_F_I=
P_CSUM | NETIF_F_RXCSUM;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tg3_flag(tp, 5755_PLUS))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 features |=3D NETIF_F_I=
PV6_CSUM;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->dev->features |=3D features;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->dev->hw_features |=3D features;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->dev->vlan_features |=3D features;
> - =A0 =A0 =A0 }
> -
> =A0 =A0 =A0 =A0/* Determine TSO capabilities */
> =A0 =A0 =A0 =A0if (GET_ASIC_REV(tp->pci_chip_rev_id) =3D=3D ASIC_REV_=
5719)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0; /* Do nothing. HW bug. */
> @@ -14922,7 +14909,7 @@ static int __devinit tg3_init_one(struct pci_=
dev *pdev,
> =A0 =A0 =A0 =A0u32 sndmbx, rcvmbx, intmbx;
> =A0 =A0 =A0 =A0char str[40];
> =A0 =A0 =A0 =A0u64 dma_mask, persist_dma_mask;
> - =A0 =A0 =A0 u32 hw_features =3D 0;
> + =A0 =A0 =A0 u32 features =3D 0;
>
> =A0 =A0 =A0 =A0printk_once(KERN_INFO "%s\n", version);
>
> @@ -14958,8 +14945,6 @@ static int __devinit tg3_init_one(struct pci_=
dev *pdev,
>
> =A0 =A0 =A0 =A0SET_NETDEV_DEV(dev, &pdev->dev);
>
> - =A0 =A0 =A0 dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN=
_RX;
> -
> =A0 =A0 =A0 =A0tp =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0tp->pdev =3D pdev;
> =A0 =A0 =A0 =A0tp->dev =3D dev;
> @@ -15039,7 +15024,7 @@ static int __devinit tg3_init_one(struct pci_=
dev *pdev,
> =A0 =A0 =A0 =A0if (dma_mask > DMA_BIT_MASK(32)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D pci_set_dma_mask(pdev, dma_mas=
k);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!err) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->features |=3D NETI=
=46_F_HIGHDMA;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 features |=3D NETIF_F_H=
IGHDMA;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D pci_set_consis=
tent_dma_mask(pdev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0persist_dma_mask);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err < 0) {
> @@ -15060,6 +15045,18 @@ static int __devinit tg3_init_one(struct pci=
_dev *pdev,
>
> =A0 =A0 =A0 =A0tg3_init_bufmgr_config(tp);
>
> + =A0 =A0 =A0 features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
> +
> + =A0 =A0 =A0 /* 5700 B0 chips do not support checksumming correctly =
due
> + =A0 =A0 =A0 =A0* to hardware bugs.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (tp->pci_chip_rev_id !=3D CHIPREV_ID_5700_B0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 features |=3D NETIF_F_SG | NETIF_F_IP_C=
SUM | NETIF_F_RXCSUM;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tg3_flag(tp, 5755_PLUS))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 features |=3D NETIF_F_I=
PV6_CSUM;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0/* TSO is on by default on chips that support hardware=
 TSO.
> =A0 =A0 =A0 =A0 * Firmware TSO on older chips gives lower performance=
, so it
> =A0 =A0 =A0 =A0 * is off by default, but can be enabled using ethtool=
=2E
> @@ -15067,24 +15064,20 @@ static int __devinit tg3_init_one(struct pc=
i_dev *pdev,
> =A0 =A0 =A0 =A0if ((tg3_flag(tp, HW_TSO_1) ||
> =A0 =A0 =A0 =A0 =A0 =A0 tg3_flag(tp, HW_TSO_2) ||
> =A0 =A0 =A0 =A0 =A0 =A0 tg3_flag(tp, HW_TSO_3)) &&
> - =A0 =A0 =A0 =A0 =A0 (dev->features & NETIF_F_IP_CSUM))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 hw_features |=3D NETIF_F_TSO;
> + =A0 =A0 =A0 =A0 =A0 (features & NETIF_F_IP_CSUM))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 features |=3D NETIF_F_TSO;
> =A0 =A0 =A0 =A0if (tg3_flag(tp, HW_TSO_2) || tg3_flag(tp, HW_TSO_3)) =
{
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dev->features & NETIF_F_IPV6_CSUM)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hw_features |=3D NETIF_=
=46_TSO6;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (features & NETIF_F_IPV6_CSUM)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 features |=3D NETIF_F_T=
SO6;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (tg3_flag(tp, HW_TSO_3) ||
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0GET_ASIC_REV(tp->pci_chip_rev_=
id) =3D=3D ASIC_REV_5761 ||
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(GET_ASIC_REV(tp->pci_chip_rev=
_id) =3D=3D ASIC_REV_5784 &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 GET_CHIP_REV(tp->pci_chip_rev=
_id) !=3D CHIPREV_5784_AX) ||
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0GET_ASIC_REV(tp->pci_chip_rev_=
id) =3D=3D ASIC_REV_5785 ||
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0GET_ASIC_REV(tp->pci_chip_rev_=
id) =3D=3D ASIC_REV_57780)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hw_features |=3D NETIF_=
=46_TSO_ECN;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 features |=3D NETIF_F_T=
SO_ECN;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 dev->hw_features |=3D hw_features;
> - =A0 =A0 =A0 dev->features |=3D hw_features;
> - =A0 =A0 =A0 dev->vlan_features |=3D hw_features;
> -
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Add loopback capability only for a subset of device=
s that support
> =A0 =A0 =A0 =A0 * MAC-LOOPBACK. Eventually this need to be enhanced t=
o allow INT-PHY
> @@ -15093,7 +15086,11 @@ static int __devinit tg3_init_one(struct pci=
_dev *pdev,
> =A0 =A0 =A0 =A0if (GET_ASIC_REV(tp->pci_chip_rev_id) !=3D ASIC_REV_57=
80 &&
> =A0 =A0 =A0 =A0 =A0 =A0!tg3_flag(tp, CPMU_PRESENT))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Add the loopback capability */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->hw_features |=3D NETIF_F_LOOPBACK;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 features |=3D NETIF_F_LOOPBACK;
> +
> + =A0 =A0 =A0 dev->features |=3D features;
This will set the loopback by default for the described sub-set.
> + =A0 =A0 =A0 dev->hw_features |=3D features;
Yes, you just want to add that here only.
> + =A0 =A0 =A0 dev->vlan_features |=3D features;
>
> =A0 =A0 =A0 =A0if (tp->pci_chip_rev_id =3D=3D CHIPREV_ID_5705_A1 &&
> =A0 =A0 =A0 =A0 =A0 =A0!tg3_flag(tp, TSO_CAPABLE) &&
> --
> 1.7.3.4
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
