From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH net-next 10/13] tg3: Consolidate all netdev feature
 assignments
Date: Thu, 19 May 2011 16:51:25 -0700
Message-ID: <20110519235124.GB774@mcarlson.broadcom.com>
References: <1305843176-32358-11-git-send-email-mcarlson@broadcom.com>
 <BANLkTim7uERxfwd2isfBUbX7WS8-X-Rj9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"David Miller" <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: "Mahesh Bandewar" <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2288 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933824Ab1ESXbs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 19:31:48 -0400
In-Reply-To: <BANLkTim7uERxfwd2isfBUbX7WS8-X-Rj9w@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2011 at 04:15:52PM -0700, Mahesh Bandewar wrote:
> On Thu, May 19, 2011 at 3:12 PM, Matt Carlson <mcarlson@broadcom.com> wrote:
> > This patch consolidates all the netdev feature bit assignments to one
> > location.
> >
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > Reviewed-by: Michael Chan <mchan@broadcom.com>
> > ---
> > ?drivers/net/tg3.c | ? 51 ++++++++++++++++++++++++---------------------------
> > ?1 files changed, 24 insertions(+), 27 deletions(-)
> >
> > diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> > index 09fe067..5bf2ce1 100644
> > --- a/drivers/net/tg3.c
> > +++ b/drivers/net/tg3.c
> > @@ -13602,19 +13602,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
> > ? ? ? ? ? ?tg3_flag(tp, 5750_PLUS))
> > ? ? ? ? ? ? ? ?tg3_flag_set(tp, 5705_PLUS);
> >
> > - ? ? ? /* 5700 B0 chips do not support checksumming correctly due
> > - ? ? ? ?* to hardware bugs.
> > - ? ? ? ?*/
> > - ? ? ? if (tp->pci_chip_rev_id != CHIPREV_ID_5700_B0) {
> > - ? ? ? ? ? ? ? u32 features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM;
> > -
> > - ? ? ? ? ? ? ? if (tg3_flag(tp, 5755_PLUS))
> > - ? ? ? ? ? ? ? ? ? ? ? features |= NETIF_F_IPV6_CSUM;
> > - ? ? ? ? ? ? ? tp->dev->features |= features;
> > - ? ? ? ? ? ? ? tp->dev->hw_features |= features;
> > - ? ? ? ? ? ? ? tp->dev->vlan_features |= features;
> > - ? ? ? }
> > -
> > ? ? ? ?/* Determine TSO capabilities */
> > ? ? ? ?if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
> > ? ? ? ? ? ? ? ?; /* Do nothing. HW bug. */
> > @@ -14922,7 +14909,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
> > ? ? ? ?u32 sndmbx, rcvmbx, intmbx;
> > ? ? ? ?char str[40];
> > ? ? ? ?u64 dma_mask, persist_dma_mask;
> > - ? ? ? u32 hw_features = 0;
> > + ? ? ? u32 features = 0;
> >
> > ? ? ? ?printk_once(KERN_INFO "%s\n", version);
> >
> > @@ -14958,8 +14945,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
> >
> > ? ? ? ?SET_NETDEV_DEV(dev, &pdev->dev);
> >
> > - ? ? ? dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
> > -
> > ? ? ? ?tp = netdev_priv(dev);
> > ? ? ? ?tp->pdev = pdev;
> > ? ? ? ?tp->dev = dev;
> > @@ -15039,7 +15024,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
> > ? ? ? ?if (dma_mask > DMA_BIT_MASK(32)) {
> > ? ? ? ? ? ? ? ?err = pci_set_dma_mask(pdev, dma_mask);
> > ? ? ? ? ? ? ? ?if (!err) {
> > - ? ? ? ? ? ? ? ? ? ? ? dev->features |= NETIF_F_HIGHDMA;
> > + ? ? ? ? ? ? ? ? ? ? ? features |= NETIF_F_HIGHDMA;
> > ? ? ? ? ? ? ? ? ? ? ? ?err = pci_set_consistent_dma_mask(pdev,
> > ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?persist_dma_mask);
> > ? ? ? ? ? ? ? ? ? ? ? ?if (err < 0) {
> > @@ -15060,6 +15045,18 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
> >
> > ? ? ? ?tg3_init_bufmgr_config(tp);
> >
> > + ? ? ? features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
> > +
> > + ? ? ? /* 5700 B0 chips do not support checksumming correctly due
> > + ? ? ? ?* to hardware bugs.
> > + ? ? ? ?*/
> > + ? ? ? if (tp->pci_chip_rev_id != CHIPREV_ID_5700_B0) {
> > + ? ? ? ? ? ? ? features |= NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM;
> > +
> > + ? ? ? ? ? ? ? if (tg3_flag(tp, 5755_PLUS))
> > + ? ? ? ? ? ? ? ? ? ? ? features |= NETIF_F_IPV6_CSUM;
> > + ? ? ? }
> > +
> > ? ? ? ?/* TSO is on by default on chips that support hardware TSO.
> > ? ? ? ? * Firmware TSO on older chips gives lower performance, so it
> > ? ? ? ? * is off by default, but can be enabled using ethtool.
> > @@ -15067,24 +15064,20 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
> > ? ? ? ?if ((tg3_flag(tp, HW_TSO_1) ||
> > ? ? ? ? ? ? tg3_flag(tp, HW_TSO_2) ||
> > ? ? ? ? ? ? tg3_flag(tp, HW_TSO_3)) &&
> > - ? ? ? ? ? (dev->features & NETIF_F_IP_CSUM))
> > - ? ? ? ? ? ? ? hw_features |= NETIF_F_TSO;
> > + ? ? ? ? ? (features & NETIF_F_IP_CSUM))
> > + ? ? ? ? ? ? ? features |= NETIF_F_TSO;
> > ? ? ? ?if (tg3_flag(tp, HW_TSO_2) || tg3_flag(tp, HW_TSO_3)) {
> > - ? ? ? ? ? ? ? if (dev->features & NETIF_F_IPV6_CSUM)
> > - ? ? ? ? ? ? ? ? ? ? ? hw_features |= NETIF_F_TSO6;
> > + ? ? ? ? ? ? ? if (features & NETIF_F_IPV6_CSUM)
> > + ? ? ? ? ? ? ? ? ? ? ? features |= NETIF_F_TSO6;
> > ? ? ? ? ? ? ? ?if (tg3_flag(tp, HW_TSO_3) ||
> > ? ? ? ? ? ? ? ? ? ?GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
> > ? ? ? ? ? ? ? ? ? ?(GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
> > ? ? ? ? ? ? ? ? ? ? GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX) ||
> > ? ? ? ? ? ? ? ? ? ?GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
> > ? ? ? ? ? ? ? ? ? ?GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
> > - ? ? ? ? ? ? ? ? ? ? ? hw_features |= NETIF_F_TSO_ECN;
> > + ? ? ? ? ? ? ? ? ? ? ? features |= NETIF_F_TSO_ECN;
> > ? ? ? ?}
> >
> > - ? ? ? dev->hw_features |= hw_features;
> > - ? ? ? dev->features |= hw_features;
> > - ? ? ? dev->vlan_features |= hw_features;
> > -
> > ? ? ? ?/*
> > ? ? ? ? * Add loopback capability only for a subset of devices that support
> > ? ? ? ? * MAC-LOOPBACK. Eventually this need to be enhanced to allow INT-PHY
> > @@ -15093,7 +15086,11 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
> > ? ? ? ?if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5780 &&
> > ? ? ? ? ? ?!tg3_flag(tp, CPMU_PRESENT))
> > ? ? ? ? ? ? ? ?/* Add the loopback capability */
> > - ? ? ? ? ? ? ? dev->hw_features |= NETIF_F_LOOPBACK;
> > + ? ? ? ? ? ? ? features |= NETIF_F_LOOPBACK;
> > +
> > + ? ? ? dev->features |= features;
> This will set the loopback by default for the described sub-set.
> > + ? ? ? dev->hw_features |= features;
> Yes, you just want to add that here only.

Yes.  Good catch.  I'll post a follow on patch ASAP.

