From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid
 not used
Date: Mon, 13 Dec 2010 14:45:10 -0800
Message-ID: <20101213224510.GB17400@mcarlson.broadcom.com>
References: <1291200914.2856.546.camel@edumazet-laptop>
 <20101205030712.36149bc2@xenia.leun.net>
 <1291536233.2806.102.camel@edumazet-laptop>
 <20101205105528.49fa9a9f@xenia.leun.net>
 <20101205114404.7c0cddc2@xenia.leun.net>
 <AANLkTikrDTCDxsyOG4m0XcrOY=3pTRwWqnPGsio9cBFj@mail.gmail.com>
 <20101206203437.54b550e0@xenia.leun.net>
 <AANLkTikKkAesHc4Fi4SwAkV0e65D0TQRztrRYoDNu3MP@mail.gmail.com>
 <20101206222703.32fbe852@xenia.leun.net>
 <AANLkTinLMCzKz7n45HdeAwNxsWjCADAkgfK+MjXVcFqh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Michael Leun" <lkml20101129@newton.leun.net>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>,
	"Ben Greear" <greearb@candelatech.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Jesse Gross" <jesse@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinLMCzKz7n45HdeAwNxsWjCADAkgfK+MjXVcFqh@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 12, 2010 at 04:11:13PM -0800, Jesse Gross wrote:
> On Mon, Dec 6, 2010 at 1:27 PM, Michael Leun
> <lkml20101129@newton.leun.net> wrote:
> > On Mon, 6 Dec 2010 12:04:48 -0800
> > Jesse Gross <jesse@nicira.com> wrote:
> >
> >> On Mon, Dec 6, 2010 at 11:34 AM, Michael Leun
> >> <lkml20101129@newton.leun.net> wrote:
> >> > On Mon, 6 Dec 2010 10:14:55 -0800
> >> > Jesse Gross <jesse@nicira.com> wrote:
> >> >
> >> >> On Sun, Dec 5, 2010 at 2:44 AM, Michael Leun
> >> >> <lkml20101129@newton.leun.net> wrote:
> >> >> > Hi Jesse,
> >> >> >
> >> >> > On Sun, 5 Dec 2010 10:55:28 +0100
> >> >> > Michael Leun <lkml20101129@newton.leun.net> wrote:
> >> >> >
> >> >> >> On Sun, 05 Dec 2010 09:03:53 +0100
> >> >> >> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> >> >>
> >> >> >> > > But on
> >> >> >> > >
> >> >> >> > > hpdl320g5:/home/ml # lspci | grep Eth
> >> >> >> > > 03:04.0 Ethernet controller: Broadcom Corporation NetXtreme
> >> >> >> > > BCM5714 Gigabit Ethernet (rev a3) 03:04.1 Ethernet
> >> >> >> > > controller: Broadcom Corporation NetXtreme BCM5714 Gigabit
> >> >> >> > > Ethernet (rev a3)
> >> >> >> > >
> >> >> >> > > the good message is that it also does not crash, but with
> >> >> >> > > tcpdump I see vlan tags when no vlan devices configured on
> >> >> >> > > the respective eth, if so I do not see tags anymore vlan
> >> >> >> > > tags on the trunk interface.
> >> >> >> > >
> >> >> >> >
> >> >> >> > For all these very specific needs, you'll have to try 2.6.37
> >> >> >> > I am afraid. Jesse did huge changes to exactly make this
> >> >> >> > working, we wont backport this to 2.6.36, but only avoid
> >> >> >> > crashes.
> >> >> >>
> >> >> >> OK, I'm perfectly fine with that, of course, actually nice to
> >> >> >> hear that the issue already is addressed.
> >> >> >>
> >> >> >> Likely I'll give some rc an shot on this machine (maybe over
> >> >> >> christmas), but it is an production machine (acutally testing
> >> >> >> other devices is the "product" produced on this machine), so
> >> >> >> unfortunately I'm not that free in when and what I can do (but
> >> >> >> the possibility to, for example, bridge the trunk interface
> >> >> >> would make testing easier, that justifies something...).
> >> >> >>
> >> >> >> Thank you all very much for your work.
> >> >> >
> >> >> > Are these changes already in 2.6.37-rc4? Or, if not are they
> >> >> > somewhere publically available already?
> >> >> >
> >> >> > I looked into various changelogs but have some difficulties to
> >> >> > identify them...
> >> >> >
> >> >> > Maybe I have some time next days to give them an try...
> >> >>
> >> >> Yes, all of the existing vlan changes are in 2.6.37-rc4. ?There
> >> >> were a number of patches but the main one was
> >> >> 3701e51382a026cba10c60b03efabe534fba4ca4
> >> >
> >> > Then, I'm afraid, this (seeing vlan tags even if vlan interfaces are
> >> > configured) does not work on HP DL320G5 (for exact description and
> >> > examples please see my mail a few days ago).
> >>
> >> What driver are you using? ?Is it tg3?
> >>
> >> The vlan changes that I made unfortunately require updating drivers to
> >> get the full benefit. ?I've been busy lately so tg3 hasn't yet been
> >> updated.
> >>
> >> I know that tg3 does some things differently depending on whether a
> >> vlan group is configured, so that would likely be the cause of what
> >> you are seeing. ?I'd have to look at it in more detail to be sure
> >> though.
> >>
> >> You said that everything works on the other Broadcom NIC that you
> >> tested? ?Maybe it uses bnx2 instead?
> >>
> >
> > Both machines use tg3 / 2.6.36.1 - one is opensuse, one ubuntu (but
> > this should not matter, I think).
> >
> > If I can do anything to support your investigations / work (most
> > likely testing / providing information) please let me know.
> 
> Unfortunately, I probably won't have time to look at this in the near
> future.  Given that the test works on one NIC but not another that
> strongly suggests that it is a driver problem, even if both NICs use
> the same driver.  I see tg3 can do different things with vlans
> depending on the model and what features are enabled.  I also ran a
> quick test on some of my machines and I didn't experience this issue.
> They are running net-next with ixgbe.
> 
> One of the main goals of my general vlan changes was to remove as much
> logic as possible from the drivers and put it in the networking core,
> so we should in theory see consistent behavior.  However, in 2.6.36
> and earlier, each driver knows about what vlan devices are configured
> and does different things with that information.
> 
> Given all of that, the most logical step to me is simply to convert
> tg3 to use the new vlan infrastructure.  It should be done regardless
> and it will probably solve this problem.  Maybe you can convince the
> Broadcom guys to do that?  It would be a lot faster for them to do it
> than me.

Below is the patch that converts the tg3 driver over to the new API.  I
don't see how it could fix the problem though.  Maybe the presence of
NETIF_F_HW_VLAN_TX changes things.

Compile tested only.

----
Subject: [PATCH] tg3: Use new VLAN code

This patch pivots the tg3 driver to the new VLAN infrastructure.

---
 drivers/net/tg3.c |   42 ++++++++----------------------------------
 1 files changed, 8 insertions(+), 34 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5faa87d..2a3f83d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -134,9 +134,6 @@
 				 TG3_TX_RING_SIZE)
 #define NEXT_TX(N)		(((N) + 1) & (TG3_TX_RING_SIZE - 1))
 
-#define TG3_RX_DMA_ALIGN		16
-#define TG3_RX_HEADROOM			ALIGN(VLAN_HLEN, TG3_RX_DMA_ALIGN)
-
 #define TG3_DMA_BYTE_ENAB		64
 
 #define TG3_RX_STD_DMA_SZ		1536
@@ -4725,8 +4722,6 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 		struct sk_buff *skb;
 		dma_addr_t dma_addr;
 		u32 opaque_key, desc_idx, *post_ptr;
-		bool hw_vlan __maybe_unused = false;
-		u16 vtag __maybe_unused = 0;
 
 		desc_idx = desc->opaque & RXD_OPAQUE_INDEX_MASK;
 		opaque_key = desc->opaque & RXD_OPAQUE_RING_MASK;
@@ -4785,12 +4780,12 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 			tg3_recycle_rx(tnapi, tpr, opaque_key,
 				       desc_idx, *post_ptr);
 
-			copy_skb = netdev_alloc_skb(tp->dev, len + VLAN_HLEN +
+			copy_skb = netdev_alloc_skb(tp->dev, len +
 						    TG3_RAW_IP_ALIGN);
 			if (copy_skb == NULL)
 				goto drop_it_no_recycle;
 
-			skb_reserve(copy_skb, TG3_RAW_IP_ALIGN + VLAN_HLEN);
+			skb_reserve(copy_skb, TG3_RAW_IP_ALIGN);
 			skb_put(copy_skb, len);
 			pci_dma_sync_single_for_cpu(tp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
 			skb_copy_from_linear_data(skb, copy_skb->data, len);
@@ -4817,30 +4812,11 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 		}
 
 		if (desc->type_flags & RXD_FLAG_VLAN &&
-		    !(tp->rx_mode & RX_MODE_KEEP_VLAN_TAG)) {
-			vtag = desc->err_vlan & RXD_VLAN_MASK;
-#if TG3_VLAN_TAG_USED
-			if (tp->vlgrp)
-				hw_vlan = true;
-			else
-#endif
-			{
-				struct vlan_ethhdr *ve = (struct vlan_ethhdr *)
-						    __skb_push(skb, VLAN_HLEN);
-
-				memmove(ve, skb->data + VLAN_HLEN,
-					ETH_ALEN * 2);
-				ve->h_vlan_proto = htons(ETH_P_8021Q);
-				ve->h_vlan_TCI = htons(vtag);
-			}
-		}
+		    !(tp->rx_mode & RX_MODE_KEEP_VLAN_TAG))
+			__vlan_hwaccel_put_tag(skb,
+					       desc->err_vlan & RXD_VLAN_MASK);
 
-#if TG3_VLAN_TAG_USED
-		if (hw_vlan)
-			vlan_gro_receive(&tnapi->napi, tp->vlgrp, vtag, skb);
-		else
-#endif
-			napi_gro_receive(&tnapi->napi, skb);
+		napi_gro_receive(&tnapi->napi, skb);
 
 		received++;
 		budget--;
@@ -13866,11 +13842,11 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	else
 		tp->tg3_flags &= ~TG3_FLAG_POLL_SERDES;
 
-	tp->rx_offset = NET_IP_ALIGN + TG3_RX_HEADROOM;
+	tp->rx_offset = NET_IP_ALIGN;
 	tp->rx_copy_thresh = TG3_RX_COPY_THRESHOLD;
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 &&
 	    (tp->tg3_flags & TG3_FLAG_PCIX_MODE) != 0) {
-		tp->rx_offset -= NET_IP_ALIGN;
+		tp->rx_offset = 0;
 #ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
 		tp->rx_copy_thresh = ~(u16)0;
 #endif
@@ -14705,9 +14681,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-#if TG3_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-#endif
 
 	tp = netdev_priv(dev);
 	tp->pdev = pdev;
-- 
1.7.2.2
