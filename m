From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Sat, 1 Dec 2007 18:37:11 -0500
Message-ID: <20071201233711.GA9698@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:43470 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752549AbXLAXhM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 18:37:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Notes:

1) Several of these are resends from the last submission.

2) That chelsio file mode change (644->755) is a bit annoying.  Can git
do chmod as a changeset by itself?


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/Kconfig                         |    4 +-
 drivers/net/amd8111e.c                      |    6 ++
 drivers/net/bfin_mac.c                      |    2 +-
 drivers/net/chelsio/cxgb2.c                 |   70 ++++++++++++----
 drivers/net/chelsio/pm3393.c                |  112 ++++++++++---------------
 drivers/net/chelsio/sge.c                   |   44 ++++------
 drivers/net/chelsio/sge.h                   |    3 +-
 drivers/net/e1000/e1000_main.c              |    2 +-
 drivers/net/ehea/ehea.h                     |    2 +-
 drivers/net/ehea/ehea_main.c                |   20 +++--
 drivers/net/ehea/ehea_qmr.h                 |    4 +-
 drivers/net/fec_mpc52xx.c                   |    2 +
 drivers/net/forcedeth.c                     |   38 ++++++---
 drivers/net/ibm_newemac/core.c              |   31 +++++---
 drivers/net/ibm_newemac/core.h              |    1 +
 drivers/net/lib82596.c                      |   50 ++++++------
 drivers/net/phy/marvell.c                   |   26 ++++--
 drivers/net/phy/phy.c                       |    3 +
 drivers/net/s2io.c                          |   32 +++++--
 drivers/net/skge.c                          |  108 +++++++++---------------
 drivers/net/sky2.c                          |  121 +++++++++++----------------
 drivers/net/sky2.h                          |   21 +++++
 drivers/net/smc911x.c                       |   19 +---
 drivers/net/smc911x.h                       |    2 +-
 drivers/net/smc91x.h                        |    2 +-
 drivers/net/tulip/dmfe.c                    |    4 +-
 drivers/net/ucc_geth.c                      |   10 ++
 drivers/net/usb/dm9601.c                    |    2 +-
 drivers/net/via-velocity.c                  |   11 +--
 drivers/net/wireless/b43/main.c             |    2 +-
 drivers/net/wireless/b43/phy.c              |    2 +-
 drivers/net/wireless/b43legacy/dma.c        |    2 +-
 drivers/net/wireless/b43legacy/main.c       |    2 +-
 drivers/net/wireless/b43legacy/phy.c        |    2 +-
 drivers/net/wireless/bcm43xx/bcm43xx_phy.c  |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   16 +++-
 drivers/net/wireless/iwlwifi/iwl4965-base.c |   13 ++-
 drivers/net/wireless/libertas/if_cs.c       |    3 +-
 drivers/net/wireless/libertas/main.c        |    4 -
 drivers/net/wireless/libertas/wext.c        |    2 +-
 drivers/net/wireless/netwave_cs.c           |    2 +-
 drivers/net/wireless/p54usb.c               |    2 +-
 drivers/s390/net/ctcmain.c                  |   45 ++++-------
 include/linux/pci_ids.h                     |    4 +
 include/linux/phy.h                         |    2 +
 45 files changed, 443 insertions(+), 414 deletions(-)
 mode change 100644 => 100755 drivers/net/chelsio/cxgb2.c
 mode change 100644 => 100755 drivers/net/chelsio/pm3393.c
 mode change 100644 => 100755 drivers/net/chelsio/sge.c
 mode change 100644 => 100755 drivers/net/chelsio/sge.h

Auke Kok (1):
      e1000: Fix NAPI state bug when Rx complete

Ayaz Abdulla (2):
      forcedeth: new mcp79 pci ids
      forcedeth boot delay fix

Benjamin Herrenschmidt (1):
      ibm_newemac: Fix possible lockup on close

David Woodhouse (3):
      libertas: Don't set NETIF_F_IPV6_CSUM in dev->features
      SET_NETDEV_DEV() in fec_mpc52xx.c
      Stop phy code from returning success to unknown ioctls.

Divy Le Ray (3):
      cxgb - fix T2 GSO
      cxgb - fix NAPI
      cxgb - fix stats

Holger Schurig (1):
      libertas: let more than one MAC event through

Jeff Garzik (1):
      dmfe: checkpatch fix (add whitespace)

Jiri Bohac (1):
      amd8111e: don't call napi_enable if configured w/o NAPI

Joe Perches (1):
      drivers/net/wireless: Add missing "space"

Joonwoo Park (2):
      iwlwifi 3945 Fix race conditional panic.
      iwlwifi 4965 Fix race conditional panic.

Kim Phillips (3):
      phylib: add PHY interface modes for internal delay for tx and rx only
      phylib: marvell: add support for TX-only and RX-only Internal Delay
      ucc_geth: handle passing of RX-only and TX-only internal delay PHY connection type parameters

Maxim Levitsky (1):
      NET: dmfe: don't access configuration space in D3 state

Mike Frysinger (1):
      Blackfin SMC91x Driver: punt CONFIG_BFIN -- we already have CONFIG_BLACKFIN

Paul Mundt (1):
      net: smc911x: only enable for mpr2 on sh.

Peter Korsgaard (4):
      dm9601: Fix printk
      smc911x: Fix undefined CONFIG_ symbol warning
      smc911x: Fix unused variable warning.
      smc911x: Fix multicast handling

Peter Tiedemann (1):
      ctc: make use of alloc_netdev()

Saleem Abdulrasool (1):
      iwlwifi: fix possible NULL dereference in iwl_set_rate()

Sreenivasa Honnur (1):
      S2io: Fixed the case when the card initialization fails on mtu change

Stefano Brivio (1):
      b43/b43legacy: fix left-over URLs and ifdefs

Stephen Hemminger (13):
      sky2: disable rx checksum on Yukon XL
      skge: FIFO Ram calculation error
      skge: receive flush logic
      skge: retry on MAC shutdown
      skge: fiber link up/down fix
      skge: increase TX threshold for Jumbo
      skge version 1.13
      skge: serial mode register values
      skge: MTU changing fix
      sky2: revert to access PCI config via device space
      sky2: don't use AER routines
      sky2: turn of dynamic Tx watermark workaround (FE+ only)
      via-velocity: don't oops on MTU change (resend)

Thomas Bogendoerfer (1):
      LIB82596: correct data types for hardware addresses

Thomas Klein (2):
      ehea: Improve tx packets counting
      ehea: Reworked rcv queue handling to log only fatal errors

Tomas Winkler (1):
      iwlwifi: fix iwl_mac_add_interface handler

Vitja Makarov (1):
      Blackfin EMAC driver: fix bug - NAT doesn't work with bfin_mac driver

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index e8d69b0..d9107e5 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -888,7 +888,7 @@ config SMC91X
 	tristate "SMC 91C9x/91C1xxx support"
 	select CRC32
 	select MII
-	depends on ARM || REDWOOD_5 || REDWOOD_6 || M32R || SUPERH || SOC_AU1X00 || BFIN
+	depends on ARM || REDWOOD_5 || REDWOOD_6 || M32R || SUPERH || SOC_AU1X00 || BLACKFIN
 	help
 	  This is a driver for SMC's 91x series of Ethernet chipsets,
 	  including the SMC91C94 and the SMC91C111. Say Y if you want it
@@ -926,7 +926,7 @@ config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
 	select MII
-	depends on ARCH_PXA || SUPERH
+	depends on ARCH_PXA || SH_MAGIC_PANEL_R2
 	help
 	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
 	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index eebf5bb..e7fdd81 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1340,7 +1340,9 @@ static int amd8111e_close(struct net_device * dev)
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	netif_stop_queue(dev);
 
+#ifdef CONFIG_AMD8111E_NAPI
 	napi_disable(&lp->napi);
+#endif
 
 	spin_lock_irq(&lp->lock);
 
@@ -1372,7 +1374,9 @@ static int amd8111e_open(struct net_device * dev )
 					 dev->name, dev))
 		return -EAGAIN;
 
+#ifdef CONFIG_AMD8111E_NAPI
 	napi_enable(&lp->napi);
+#endif
 
 	spin_lock_irq(&lp->lock);
 
@@ -1380,7 +1384,9 @@ static int amd8111e_open(struct net_device * dev )
 
 	if(amd8111e_restart(dev)){
 		spin_unlock_irq(&lp->lock);
+#ifdef CONFIG_AMD8111E_NAPI
 		napi_disable(&lp->napi);
+#endif
 		if (dev->irq)
 			free_irq(dev->irq, dev);
 		return -ENOMEM;
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 0b99b55..eb97175 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -676,7 +676,7 @@ static void bf537mac_rx(struct net_device *dev)
 	skb->protocol = eth_type_trans(skb, dev);
 #if defined(BFIN_MAC_CSUM_OFFLOAD)
 	skb->csum = current_rx_ptr->status.ip_payload_csum;
-	skb->ip_summed = CHECKSUM_PARTIAL;
+	skb->ip_summed = CHECKSUM_COMPLETE;
 #endif
 
 	netif_rx(skb);
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
old mode 100644
new mode 100755
index 2dbf8dc..c597504
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -374,7 +374,9 @@ static char stats_strings[][ETH_GSTRING_LEN] = {
 	"TxInternalMACXmitError",
 	"TxFramesWithExcessiveDeferral",
 	"TxFCSErrors",
-
+	"TxJumboFramesOk",
+	"TxJumboOctetsOk",
+	
 	"RxOctetsOK",
 	"RxOctetsBad",
 	"RxUnicastFramesOK",
@@ -392,16 +394,17 @@ static char stats_strings[][ETH_GSTRING_LEN] = {
 	"RxInRangeLengthErrors",
 	"RxOutOfRangeLengthField",
 	"RxFrameTooLongErrors",
+	"RxJumboFramesOk",
+	"RxJumboOctetsOk",
 
 	/* Port stats */
-	"RxPackets",
 	"RxCsumGood",
-	"TxPackets",
 	"TxCsumOffload",
 	"TxTso",
 	"RxVlan",
 	"TxVlan",
-
+	"TxNeedHeadroom", 
+	
 	/* Interrupt stats */
 	"rx drops",
 	"pure_rsps",
@@ -463,23 +466,56 @@ static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
 	const struct cmac_statistics *s;
 	const struct sge_intr_counts *t;
 	struct sge_port_stats ss;
-	unsigned int len;
 
 	s = mac->ops->statistics_update(mac, MAC_STATS_UPDATE_FULL);
-
-	len = sizeof(u64)*(&s->TxFCSErrors + 1 - &s->TxOctetsOK);
-	memcpy(data, &s->TxOctetsOK, len);
-	data += len;
-
-	len = sizeof(u64)*(&s->RxFrameTooLongErrors + 1 - &s->RxOctetsOK);
-	memcpy(data, &s->RxOctetsOK, len);
-	data += len;
-
+	t = t1_sge_get_intr_counts(adapter->sge);
 	t1_sge_get_port_stats(adapter->sge, dev->if_port, &ss);
-	memcpy(data, &ss, sizeof(ss));
-	data += sizeof(ss);
 
-	t = t1_sge_get_intr_counts(adapter->sge);
+	*data++ = s->TxOctetsOK;
+	*data++ = s->TxOctetsBad;
+	*data++ = s->TxUnicastFramesOK;
+	*data++ = s->TxMulticastFramesOK;
+	*data++ = s->TxBroadcastFramesOK;
+	*data++ = s->TxPauseFrames;
+	*data++ = s->TxFramesWithDeferredXmissions;
+	*data++ = s->TxLateCollisions;
+	*data++ = s->TxTotalCollisions;
+	*data++ = s->TxFramesAbortedDueToXSCollisions;
+	*data++ = s->TxUnderrun;
+	*data++ = s->TxLengthErrors;
+	*data++ = s->TxInternalMACXmitError;
+	*data++ = s->TxFramesWithExcessiveDeferral;
+	*data++ = s->TxFCSErrors;
+	*data++ = s->TxJumboFramesOK;
+	*data++ = s->TxJumboOctetsOK;
+
+	*data++ = s->RxOctetsOK;
+	*data++ = s->RxOctetsBad;
+	*data++ = s->RxUnicastFramesOK;
+	*data++ = s->RxMulticastFramesOK;
+	*data++ = s->RxBroadcastFramesOK;
+	*data++ = s->RxPauseFrames;
+	*data++ = s->RxFCSErrors;
+	*data++ = s->RxAlignErrors;
+	*data++ = s->RxSymbolErrors;
+	*data++ = s->RxDataErrors;
+	*data++ = s->RxSequenceErrors;
+	*data++ = s->RxRuntErrors;
+	*data++ = s->RxJabberErrors;
+	*data++ = s->RxInternalMACRcvError;
+	*data++ = s->RxInRangeLengthErrors;
+	*data++ = s->RxOutOfRangeLengthField;
+	*data++ = s->RxFrameTooLongErrors;
+	*data++ = s->RxJumboFramesOK;
+	*data++ = s->RxJumboOctetsOK;
+
+	*data++ = ss.rx_cso_good;
+	*data++ = ss.tx_cso;
+	*data++ = ss.tx_tso;
+	*data++ = ss.vlan_xtract;
+	*data++ = ss.vlan_insert;
+	*data++ = ss.tx_need_hdrroom;
+	
 	*data++ = t->rx_drops;
 	*data++ = t->pure_rsps;
 	*data++ = t->unhandled_irqs;
diff --git a/drivers/net/chelsio/pm3393.c b/drivers/net/chelsio/pm3393.c
old mode 100644
new mode 100755
index 678778a..2117c4f
--- a/drivers/net/chelsio/pm3393.c
+++ b/drivers/net/chelsio/pm3393.c
@@ -45,7 +45,7 @@
 
 #include <linux/crc32.h>
 
-#define OFFSET(REG_ADDR)    (REG_ADDR << 2)
+#define OFFSET(REG_ADDR)    ((REG_ADDR) << 2)
 
 /* Max frame size PM3393 can handle. Includes Ethernet header and CRC. */
 #define MAX_FRAME_SIZE  9600
@@ -428,69 +428,26 @@ static int pm3393_set_speed_duplex_fc(struct cmac *cmac, int speed, int duplex,
 	return 0;
 }
 
-static void pm3393_rmon_update(struct adapter *adapter, u32 offs, u64 *val,
-			       int over)
-{
-	u32 val0, val1, val2;
-
-	t1_tpi_read(adapter, offs, &val0);
-	t1_tpi_read(adapter, offs + 4, &val1);
-	t1_tpi_read(adapter, offs + 8, &val2);
-
-	*val &= ~0ull << 40;
-	*val |= val0 & 0xffff;
-	*val |= (val1 & 0xffff) << 16;
-	*val |= (u64)(val2 & 0xff) << 32;
-
-	if (over)
-		*val += 1ull << 40;
+#define RMON_UPDATE(mac, name, stat_name) \
+{ \
+	t1_tpi_read((mac)->adapter, OFFSET(name), &val0);     \
+	t1_tpi_read((mac)->adapter, OFFSET((name)+1), &val1); \
+	t1_tpi_read((mac)->adapter, OFFSET((name)+2), &val2); \
+	(mac)->stats.stat_name = (u64)(val0 & 0xffff) | \
+				 ((u64)(val1 & 0xffff) << 16) | \
+				 ((u64)(val2 & 0xff) << 32) | \
+				 ((mac)->stats.stat_name & \
+					0xffffff0000000000ULL); \
+	if (ro & \
+	    (1ULL << ((name - SUNI1x10GEXP_REG_MSTAT_COUNTER_0_LOW) >> 2))) \
+		(mac)->stats.stat_name += 1ULL << 40; \
 }
 
 static const struct cmac_statistics *pm3393_update_statistics(struct cmac *mac,
 							      int flag)
 {
-	static struct {
-		unsigned int reg;
-		unsigned int offset;
-	} hw_stats [] = {
-
-#define HW_STAT(name, stat_name) \
-	{ name, (&((struct cmac_statistics *)NULL)->stat_name) - (u64 *)NULL }
-
-		/* Rx stats */
-		HW_STAT(RxOctetsReceivedOK, RxOctetsOK),
-		HW_STAT(RxUnicastFramesReceivedOK, RxUnicastFramesOK),
-		HW_STAT(RxMulticastFramesReceivedOK, RxMulticastFramesOK),
-		HW_STAT(RxBroadcastFramesReceivedOK, RxBroadcastFramesOK),
-		HW_STAT(RxPAUSEMACCtrlFramesReceived, RxPauseFrames),
-		HW_STAT(RxFrameCheckSequenceErrors, RxFCSErrors),
-		HW_STAT(RxFramesLostDueToInternalMACErrors,
-				RxInternalMACRcvError),
-		HW_STAT(RxSymbolErrors, RxSymbolErrors),
-		HW_STAT(RxInRangeLengthErrors, RxInRangeLengthErrors),
-		HW_STAT(RxFramesTooLongErrors , RxFrameTooLongErrors),
-		HW_STAT(RxJabbers, RxJabberErrors),
-		HW_STAT(RxFragments, RxRuntErrors),
-		HW_STAT(RxUndersizedFrames, RxRuntErrors),
-		HW_STAT(RxJumboFramesReceivedOK, RxJumboFramesOK),
-		HW_STAT(RxJumboOctetsReceivedOK, RxJumboOctetsOK),
-
-		/* Tx stats */
-		HW_STAT(TxOctetsTransmittedOK, TxOctetsOK),
-		HW_STAT(TxFramesLostDueToInternalMACTransmissionError,
-				TxInternalMACXmitError),
-		HW_STAT(TxTransmitSystemError, TxFCSErrors),
-		HW_STAT(TxUnicastFramesTransmittedOK, TxUnicastFramesOK),
-		HW_STAT(TxMulticastFramesTransmittedOK, TxMulticastFramesOK),
-		HW_STAT(TxBroadcastFramesTransmittedOK, TxBroadcastFramesOK),
-		HW_STAT(TxPAUSEMACCtrlFramesTransmitted, TxPauseFrames),
-		HW_STAT(TxJumboFramesReceivedOK, TxJumboFramesOK),
-		HW_STAT(TxJumboOctetsReceivedOK, TxJumboOctetsOK)
-	}, *p = hw_stats;
-	u64 ro;
-	u32 val0, val1, val2, val3;
-	u64 *stats = (u64 *) &mac->stats;
-	unsigned int i;
+	u64	ro;
+	u32	val0, val1, val2, val3;
 
 	/* Snap the counters */
 	pmwrite(mac, SUNI1x10GEXP_REG_MSTAT_CONTROL,
@@ -504,14 +461,35 @@ static const struct cmac_statistics *pm3393_update_statistics(struct cmac *mac,
 	ro = ((u64)val0 & 0xffff) | (((u64)val1 & 0xffff) << 16) |
 		(((u64)val2 & 0xffff) << 32) | (((u64)val3 & 0xffff) << 48);
 
-	for (i = 0; i < ARRAY_SIZE(hw_stats); i++) {
-		unsigned reg = p->reg - SUNI1x10GEXP_REG_MSTAT_COUNTER_0_LOW;
-
-		pm3393_rmon_update((mac)->adapter, OFFSET(p->reg),
-				   stats + p->offset, ro & (reg >> 2));
-	}
-
-
+	/* Rx stats */
+	RMON_UPDATE(mac, RxOctetsReceivedOK, RxOctetsOK);
+	RMON_UPDATE(mac, RxUnicastFramesReceivedOK, RxUnicastFramesOK);
+	RMON_UPDATE(mac, RxMulticastFramesReceivedOK, RxMulticastFramesOK);
+	RMON_UPDATE(mac, RxBroadcastFramesReceivedOK, RxBroadcastFramesOK);
+	RMON_UPDATE(mac, RxPAUSEMACCtrlFramesReceived, RxPauseFrames);
+	RMON_UPDATE(mac, RxFrameCheckSequenceErrors, RxFCSErrors);
+	RMON_UPDATE(mac, RxFramesLostDueToInternalMACErrors,
+				RxInternalMACRcvError);
+	RMON_UPDATE(mac, RxSymbolErrors, RxSymbolErrors);
+	RMON_UPDATE(mac, RxInRangeLengthErrors, RxInRangeLengthErrors);
+	RMON_UPDATE(mac, RxFramesTooLongErrors , RxFrameTooLongErrors);
+	RMON_UPDATE(mac, RxJabbers, RxJabberErrors);
+	RMON_UPDATE(mac, RxFragments, RxRuntErrors);
+	RMON_UPDATE(mac, RxUndersizedFrames, RxRuntErrors);
+	RMON_UPDATE(mac, RxJumboFramesReceivedOK, RxJumboFramesOK);
+	RMON_UPDATE(mac, RxJumboOctetsReceivedOK, RxJumboOctetsOK);
+
+	/* Tx stats */
+	RMON_UPDATE(mac, TxOctetsTransmittedOK, TxOctetsOK);
+	RMON_UPDATE(mac, TxFramesLostDueToInternalMACTransmissionError,
+				TxInternalMACXmitError);
+	RMON_UPDATE(mac, TxTransmitSystemError, TxFCSErrors);
+	RMON_UPDATE(mac, TxUnicastFramesTransmittedOK, TxUnicastFramesOK);
+	RMON_UPDATE(mac, TxMulticastFramesTransmittedOK, TxMulticastFramesOK);
+	RMON_UPDATE(mac, TxBroadcastFramesTransmittedOK, TxBroadcastFramesOK);
+	RMON_UPDATE(mac, TxPAUSEMACCtrlFramesTransmitted, TxPauseFrames);
+	RMON_UPDATE(mac, TxJumboFramesReceivedOK, TxJumboFramesOK);
+	RMON_UPDATE(mac, TxJumboOctetsReceivedOK, TxJumboOctetsOK);
 
 	return &mac->stats;
 }
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
old mode 100644
new mode 100755
index 4436662..b301c04
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -986,11 +986,10 @@ void t1_sge_get_port_stats(const struct sge *sge, int port,
 	for_each_possible_cpu(cpu) {
 		struct sge_port_stats *st = per_cpu_ptr(sge->port_stats[port], cpu);
 
-		ss->rx_packets += st->rx_packets;
 		ss->rx_cso_good += st->rx_cso_good;
-		ss->tx_packets += st->tx_packets;
 		ss->tx_cso += st->tx_cso;
 		ss->tx_tso += st->tx_tso;
+		ss->tx_need_hdrroom += st->tx_need_hdrroom;
 		ss->vlan_xtract += st->vlan_xtract;
 		ss->vlan_insert += st->vlan_insert;
 	}
@@ -1380,7 +1379,6 @@ static void sge_rx(struct sge *sge, struct freelQ *fl, unsigned int len)
 	__skb_pull(skb, sizeof(*p));
 
 	st = per_cpu_ptr(sge->port_stats[p->iff], smp_processor_id());
-	st->rx_packets++;
 
 	skb->protocol = eth_type_trans(skb, adapter->port[p->iff].dev);
 	skb->dev->last_rx = jiffies;
@@ -1624,11 +1622,9 @@ int t1_poll(struct napi_struct *napi, int budget)
 {
 	struct adapter *adapter = container_of(napi, struct adapter, napi);
 	struct net_device *dev = adapter->port[0].dev;
-	int work_done;
-
-	work_done = process_responses(adapter, budget);
+	int work_done = process_responses(adapter, budget);
 
-	if (likely(!responses_pending(adapter))) {
+	if (likely(work_done < budget)) {
 		netif_rx_complete(dev, napi);
 		writel(adapter->sge->respQ.cidx,
 		       adapter->regs + A_SG_SLEEPING);
@@ -1848,7 +1844,8 @@ int t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct adapter *adapter = dev->priv;
 	struct sge *sge = adapter->sge;
-	struct sge_port_stats *st = per_cpu_ptr(sge->port_stats[dev->if_port], smp_processor_id());
+	struct sge_port_stats *st = per_cpu_ptr(sge->port_stats[dev->if_port],
+						smp_processor_id());
 	struct cpl_tx_pkt *cpl;
 	struct sk_buff *orig_skb = skb;
 	int ret;
@@ -1856,6 +1853,18 @@ int t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (skb->protocol == htons(ETH_P_CPL5))
 		goto send;
 
+	/*
+	 * We are using a non-standard hard_header_len.
+	 * Allocate more header room in the rare cases it is not big enough.
+	 */
+	if (unlikely(skb_headroom(skb) < dev->hard_header_len - ETH_HLEN)) {
+		skb = skb_realloc_headroom(skb, sizeof(struct cpl_tx_pkt_lso));
+		++st->tx_need_hdrroom;
+		dev_kfree_skb_any(orig_skb);
+		if (!skb)
+			return NETDEV_TX_OK;
+	}
+
 	if (skb_shinfo(skb)->gso_size) {
 		int eth_type;
 		struct cpl_tx_pkt_lso *hdr;
@@ -1889,24 +1898,6 @@ int t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			return NETDEV_TX_OK;
 		}
 
-		/*
-		 * We are using a non-standard hard_header_len and some kernel
-		 * components, such as pktgen, do not handle it right.
-		 * Complain when this happens but try to fix things up.
-		 */
-		if (unlikely(skb_headroom(skb) < dev->hard_header_len - ETH_HLEN)) {
-			pr_debug("%s: headroom %d header_len %d\n", dev->name,
-				 skb_headroom(skb), dev->hard_header_len);
-
-			if (net_ratelimit())
-				printk(KERN_ERR "%s: inadequate headroom in "
-				       "Tx packet\n", dev->name);
-			skb = skb_realloc_headroom(skb, sizeof(*cpl));
-			dev_kfree_skb_any(orig_skb);
-			if (!skb)
-				return NETDEV_TX_OK;
-		}
-
 		if (!(adapter->flags & UDP_CSUM_CAPABLE) &&
 		    skb->ip_summed == CHECKSUM_PARTIAL &&
 		    ip_hdr(skb)->protocol == IPPROTO_UDP) {
@@ -1952,7 +1943,6 @@ int t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		cpl->vlan_valid = 0;
 
 send:
-	st->tx_packets++;
 	dev->trans_start = jiffies;
 	ret = t1_sge_tx(skb, adapter, 0, dev);
 
diff --git a/drivers/net/chelsio/sge.h b/drivers/net/chelsio/sge.h
old mode 100644
new mode 100755
index 713d9c5..cced9df
--- a/drivers/net/chelsio/sge.h
+++ b/drivers/net/chelsio/sge.h
@@ -57,13 +57,12 @@ struct sge_intr_counts {
 };
 
 struct sge_port_stats {
-	u64 rx_packets;      /* # of Ethernet packets received */
 	u64 rx_cso_good;     /* # of successful RX csum offloads */
-	u64 tx_packets;      /* # of TX packets */
 	u64 tx_cso;          /* # of TX checksum offloads */
 	u64 tx_tso;          /* # of TSO requests */
 	u64 vlan_xtract;     /* # of VLAN tag extractions */
 	u64 vlan_insert;     /* # of VLAN tag insertions */
+	u64 tx_need_hdrroom; /* # of TX skbs in need of more header room */
 };
 
 struct sk_buff;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index cf39473..4f37506 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3942,7 +3942,7 @@ e1000_clean(struct napi_struct *napi, int budget)
 	                  &work_done, budget);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((!tx_cleaned && (work_done < budget)) ||
+	if ((!tx_cleaned && (work_done == 0)) ||
 	   !netif_running(poll_dev)) {
 quit_polling:
 		if (likely(adapter->itr_setting & 3))
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index f78e5bf..5f82a46 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0080"
+#define DRV_VERSION	"EHEA_0083"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index f0319f1..869e160 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -136,7 +136,7 @@ static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 	struct ehea_port *port = netdev_priv(dev);
 	struct net_device_stats *stats = &port->stats;
 	struct hcp_ehea_port_cb2 *cb2;
-	u64 hret, rx_packets;
+	u64 hret, rx_packets, tx_packets;
 	int i;
 
 	memset(stats, 0, sizeof(*stats));
@@ -162,7 +162,11 @@ static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 	for (i = 0; i < port->num_def_qps; i++)
 		rx_packets += port->port_res[i].rx_packets;
 
-	stats->tx_packets = cb2->txucp + cb2->txmcp + cb2->txbcp;
+	tx_packets = 0;
+	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++)
+		tx_packets += port->port_res[i].tx_packets;
+
+	stats->tx_packets = tx_packets;
 	stats->multicast = cb2->rxmcp;
 	stats->rx_errors = cb2->rxuerr;
 	stats->rx_bytes = cb2->rxo;
@@ -406,11 +410,6 @@ static int ehea_treat_poll_error(struct ehea_port_res *pr, int rq,
 	if (cqe->status & EHEA_CQE_STAT_ERR_CRC)
 		pr->p_stats.err_frame_crc++;
 
-	if (netif_msg_rx_err(pr->port)) {
-		ehea_error("CQE Error for QP %d", pr->qp->init_attr.qp_nr);
-		ehea_dump(cqe, sizeof(*cqe), "CQE");
-	}
-
 	if (rq == 2) {
 		*processed_rq2 += 1;
 		skb = get_skb_by_index(pr->rq2_skba.arr, pr->rq2_skba.len, cqe);
@@ -422,7 +421,11 @@ static int ehea_treat_poll_error(struct ehea_port_res *pr, int rq,
 	}
 
 	if (cqe->status & EHEA_CQE_STAT_FAT_ERR_MASK) {
-		ehea_error("Critical receive error. Resetting port.");
+		if (netif_msg_rx_err(pr->port)) {
+			ehea_error("Critical receive error for QP %d. "
+				   "Resetting port.", pr->qp->init_attr.qp_nr);
+			ehea_dump(cqe, sizeof(*cqe), "CQE");
+		}
 		schedule_work(&pr->port->reset_task);
 		return 1;
 	}
@@ -2000,6 +2003,7 @@ static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	ehea_post_swqe(pr->qp, swqe);
+	pr->tx_packets++;
 
 	if (unlikely(atomic_read(&pr->swqe_avail) <= 1)) {
 		spin_lock_irqsave(&pr->netif_queue, flags);
diff --git a/drivers/net/ehea/ehea_qmr.h b/drivers/net/ehea/ehea_qmr.h
index 562de0e..bc62d38 100644
--- a/drivers/net/ehea/ehea_qmr.h
+++ b/drivers/net/ehea/ehea_qmr.h
@@ -145,8 +145,8 @@ struct ehea_rwqe {
 #define EHEA_CQE_VLAN_TAG_XTRACT   0x0400
 
 #define EHEA_CQE_TYPE_RQ           0x60
-#define EHEA_CQE_STAT_ERR_MASK     0x720F
-#define EHEA_CQE_STAT_FAT_ERR_MASK 0x1F
+#define EHEA_CQE_STAT_ERR_MASK     0x700F
+#define EHEA_CQE_STAT_FAT_ERR_MASK 0xF
 #define EHEA_CQE_STAT_ERR_TCP      0x4000
 #define EHEA_CQE_STAT_ERR_IP       0x2000
 #define EHEA_CQE_STAT_ERR_CRC      0x1000
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index a8a0ee2..bf5a7ca 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -971,6 +971,8 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 
 	mpc52xx_fec_reset_stats(ndev);
 
+	SET_NETDEV_DEV(ndev, &op->dev);
+
 	/* Register the new network device */
 	rv = register_netdev(ndev);
 	if (rv < 0)
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 92ce2e3..a96583c 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5286,19 +5286,15 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		if (readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_PHY_INIT) {
 			np->mac_in_use = readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_MGMT_ST;
 			dprintk(KERN_INFO "%s: mgmt unit is running. mac in use %x.\n", pci_name(pci_dev), np->mac_in_use);
-			for (i = 0; i < 5000; i++) {
-				msleep(1);
-				if (nv_mgmt_acquire_sema(dev)) {
-					/* management unit setup the phy already? */
-					if ((readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_MASK) ==
-					    NVREG_XMITCTL_SYNC_PHY_INIT) {
-						/* phy is inited by mgmt unit */
-						phyinitialized = 1;
-						dprintk(KERN_INFO "%s: Phy already initialized by mgmt unit.\n", pci_name(pci_dev));
-					} else {
-						/* we need to init the phy */
-					}
-					break;
+			if (nv_mgmt_acquire_sema(dev)) {
+				/* management unit setup the phy already? */
+				if ((readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_MASK) ==
+				    NVREG_XMITCTL_SYNC_PHY_INIT) {
+					/* phy is inited by mgmt unit */
+					phyinitialized = 1;
+					dprintk(KERN_INFO "%s: Phy already initialized by mgmt unit.\n", pci_name(pci_dev));
+				} else {
+					/* we need to init the phy */
 				}
 			}
 		}
@@ -5613,6 +5609,22 @@ static struct pci_device_id pci_tbl[] = {
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_35),
 		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
+	{	/* MCP79 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_36),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
+	{	/* MCP79 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_37),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
+	{	/* MCP79 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_38),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
+	{	/* MCP79 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_39),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
 	{0,},
 };
 
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 0de3aa2..eb0718b 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -642,9 +642,11 @@ static void emac_reset_work(struct work_struct *work)
 	DBG(dev, "reset_work" NL);
 
 	mutex_lock(&dev->link_lock);
-	emac_netif_stop(dev);
-	emac_full_tx_reset(dev);
-	emac_netif_start(dev);
+	if (dev->opened) {
+		emac_netif_stop(dev);
+		emac_full_tx_reset(dev);
+		emac_netif_start(dev);
+	}
 	mutex_unlock(&dev->link_lock);
 }
 
@@ -1063,10 +1065,9 @@ static int emac_open(struct net_device *ndev)
 	dev->rx_sg_skb = NULL;
 
 	mutex_lock(&dev->link_lock);
+	dev->opened = 1;
 
-	/* XXX Start PHY polling now. Shouldn't wr do like sungem instead and
-	 * always poll the PHY even when the iface is down ? That would allow
-	 * things like laptop-net to work. --BenH
+	/* Start PHY polling now.
 	 */
 	if (dev->phy.address >= 0) {
 		int link_poll_interval;
@@ -1145,9 +1146,11 @@ static void emac_link_timer(struct work_struct *work)
 	int link_poll_interval;
 
 	mutex_lock(&dev->link_lock);
-
 	DBG2(dev, "link timer" NL);
 
+	if (!dev->opened)
+		goto bail;
+
 	if (dev->phy.def->ops->poll_link(&dev->phy)) {
 		if (!netif_carrier_ok(dev->ndev)) {
 			/* Get new link parameters */
@@ -1170,13 +1173,14 @@ static void emac_link_timer(struct work_struct *work)
 		link_poll_interval = PHY_POLL_LINK_OFF;
 	}
 	schedule_delayed_work(&dev->link_work, link_poll_interval);
-
+ bail:
 	mutex_unlock(&dev->link_lock);
 }
 
 static void emac_force_link_update(struct emac_instance *dev)
 {
 	netif_carrier_off(dev->ndev);
+	smp_rmb();
 	if (dev->link_polling) {
 		cancel_rearming_delayed_work(&dev->link_work);
 		if (dev->link_polling)
@@ -1191,11 +1195,14 @@ static int emac_close(struct net_device *ndev)
 
 	DBG(dev, "close" NL);
 
-	if (dev->phy.address >= 0)
+	if (dev->phy.address >= 0) {
+		dev->link_polling = 0;
 		cancel_rearming_delayed_work(&dev->link_work);
-
+	}
+	mutex_lock(&dev->link_lock);
 	emac_netif_stop(dev);
-	flush_scheduled_work();
+	dev->opened = 0;
+	mutex_unlock(&dev->link_lock);
 
 	emac_rx_disable(dev);
 	emac_tx_disable(dev);
@@ -2756,6 +2763,8 @@ static int __devexit emac_remove(struct of_device *ofdev)
 
 	unregister_netdev(dev->ndev);
 
+	flush_scheduled_work();
+
 	if (emac_has_feature(dev, EMAC_FTR_HAS_TAH))
 		tah_detach(dev->tah_dev, dev->tah_port);
 	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII))
diff --git a/drivers/net/ibm_newemac/core.h b/drivers/net/ibm_newemac/core.h
index 4011803..a010b24 100644
--- a/drivers/net/ibm_newemac/core.h
+++ b/drivers/net/ibm_newemac/core.h
@@ -258,6 +258,7 @@ struct emac_instance {
 	int				stop_timeout;	/* in us */
 	int				no_mcast;
 	int				mcast_pending;
+	int				opened;
 	struct work_struct		reset_work;
 	spinlock_t			lock;
 };
diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
index 9a855e5..b59f442 100644
--- a/drivers/net/lib82596.c
+++ b/drivers/net/lib82596.c
@@ -176,8 +176,8 @@ struct i596_reg {
 struct i596_tbd {
 	unsigned short size;
 	unsigned short pad;
-	dma_addr_t     next;
-	dma_addr_t     data;
+	u32            next;
+	u32            data;
 	u32 cache_pad[5];		/* Total 32 bytes... */
 };
 
@@ -195,12 +195,12 @@ struct i596_cmd {
 	struct i596_cmd *v_next;	/* Address from CPUs viewpoint */
 	unsigned short status;
 	unsigned short command;
-	dma_addr_t     b_next;	/* Address from i596 viewpoint */
+	u32            b_next;	/* Address from i596 viewpoint */
 };
 
 struct tx_cmd {
 	struct i596_cmd cmd;
-	dma_addr_t     tbd;
+	u32            tbd;
 	unsigned short size;
 	unsigned short pad;
 	struct sk_buff *skb;		/* So we can free it after tx */
@@ -237,8 +237,8 @@ struct cf_cmd {
 struct i596_rfd {
 	unsigned short stat;
 	unsigned short cmd;
-	dma_addr_t     b_next;	/* Address from i596 viewpoint */
-	dma_addr_t     rbd;
+	u32            b_next;	/* Address from i596 viewpoint */
+	u32            rbd;
 	unsigned short count;
 	unsigned short size;
 	struct i596_rfd *v_next;	/* Address from CPUs viewpoint */
@@ -249,18 +249,18 @@ struct i596_rfd {
 };
 
 struct i596_rbd {
-    /* hardware data */
-    unsigned short count;
-    unsigned short zero1;
-    dma_addr_t     b_next;
-    dma_addr_t     b_data;		/* Address from i596 viewpoint */
-    unsigned short size;
-    unsigned short zero2;
-    /* driver data */
-    struct sk_buff *skb;
-    struct i596_rbd *v_next;
-    dma_addr_t     b_addr;		/* This rbd addr from i596 view */
-    unsigned char *v_data;		/* Address from CPUs viewpoint */
+	/* hardware data */
+	unsigned short count;
+	unsigned short zero1;
+	u32            b_next;
+	u32            b_data;		/* Address from i596 viewpoint */
+	unsigned short size;
+	unsigned short zero2;
+	/* driver data */
+	struct sk_buff *skb;
+	struct i596_rbd *v_next;
+	u32            b_addr;		/* This rbd addr from i596 view */
+	unsigned char *v_data;		/* Address from CPUs viewpoint */
 					/* Total 32 bytes... */
 #ifdef __LP64__
     u32 cache_pad[4];
@@ -275,8 +275,8 @@ struct i596_rbd {
 struct i596_scb {
 	unsigned short status;
 	unsigned short command;
-	dma_addr_t    cmd;
-	dma_addr_t    rfd;
+	u32           cmd;
+	u32           rfd;
 	u32           crc_err;
 	u32           align_err;
 	u32           resource_err;
@@ -288,14 +288,14 @@ struct i596_scb {
 };
 
 struct i596_iscp {
-	u32           stat;
-	dma_addr_t    scb;
+	u32 stat;
+	u32 scb;
 };
 
 struct i596_scp {
-	u32           sysbus;
-	u32           pad;
-	dma_addr_t    iscp;
+	u32 sysbus;
+	u32 pad;
+	u32 iscp;
 };
 
 struct i596_dma {
diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 035fd41..f057407 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -143,21 +143,29 @@ static int m88e1111_config_init(struct phy_device *phydev)
 	int err;
 
 	if ((phydev->interface == PHY_INTERFACE_MODE_RGMII) ||
-	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)) {
+	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) ||
+	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
+	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)) {
 		int temp;
 
-		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) {
-			temp = phy_read(phydev, MII_M1111_PHY_EXT_CR);
-			if (temp < 0)
-				return temp;
+		temp = phy_read(phydev, MII_M1111_PHY_EXT_CR);
+		if (temp < 0)
+			return temp;
 
+		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) {
 			temp |= (MII_M1111_RX_DELAY | MII_M1111_TX_DELAY);
-
-			err = phy_write(phydev, MII_M1111_PHY_EXT_CR, temp);
-			if (err < 0)
-				return err;
+		} else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) {
+			temp &= ~MII_M1111_TX_DELAY;
+			temp |= MII_M1111_RX_DELAY;
+		} else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID) {
+			temp &= ~MII_M1111_RX_DELAY;
+			temp |= MII_M1111_TX_DELAY;
 		}
 
+		err = phy_write(phydev, MII_M1111_PHY_EXT_CR, temp);
+		if (err < 0)
+			return err;
+
 		temp = phy_read(phydev, MII_M1111_PHY_EXT_SR);
 		if (temp < 0)
 			return temp;
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 9bc1177..7c9e6e3 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -406,6 +406,9 @@ int phy_mii_ioctl(struct phy_device *phydev,
 				&& phydev->drv->config_init)
 			phydev->drv->config_init(phydev);
 		break;
+
+	default:
+		return -ENOTTY;
 	}
 
 	return 0;
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 6326667..d5113dd 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -1081,7 +1081,7 @@ static int init_nic(struct s2io_nic *nic)
 	/* to set the swapper controle on the card */
 	if(s2io_set_swapper(nic)) {
 		DBG_PRINT(ERR_DBG,"ERROR: Setting Swapper failed\n");
-		return -1;
+		return -EIO;
 	}
 
 	/*
@@ -1503,7 +1503,7 @@ static int init_nic(struct s2io_nic *nic)
 			DBG_PRINT(ERR_DBG, "%s: failed rts ds steering",
 				dev->name);
 			DBG_PRINT(ERR_DBG, "set on codepoint %d\n", i);
-			return FAILURE;
+			return -ENODEV;
 		}
 	}
 
@@ -1570,7 +1570,7 @@ static int init_nic(struct s2io_nic *nic)
 		if (time > 10) {
 			DBG_PRINT(ERR_DBG, "%s: TTI init Failed\n",
 				  dev->name);
-			return -1;
+			return -ENODEV;
 		}
 		msleep(50);
 		time++;
@@ -1623,7 +1623,7 @@ static int init_nic(struct s2io_nic *nic)
 			if (time > 10) {
 				DBG_PRINT(ERR_DBG, "%s: RTI init Failed\n",
 					  dev->name);
-				return -1;
+				return -ENODEV;
 			}
 			time++;
 			msleep(50);
@@ -3914,6 +3914,12 @@ static int s2io_close(struct net_device *dev)
 {
 	struct s2io_nic *sp = dev->priv;
 
+	/* Return if the device is already closed               *
+	*  Can happen when s2io_card_up failed in change_mtu    *
+	*/
+	if (!is_s2io_card_up(sp))
+		return 0;
+
 	netif_stop_queue(dev);
 	napi_disable(&sp->napi);
 	/* Reset card, kill tasklet and free Tx and Rx buffers. */
@@ -6355,6 +6361,7 @@ static int s2io_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 static int s2io_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct s2io_nic *sp = dev->priv;
+	int ret = 0;
 
 	if ((new_mtu < MIN_MTU) || (new_mtu > S2IO_JUMBO_SIZE)) {
 		DBG_PRINT(ERR_DBG, "%s: MTU size is invalid.\n",
@@ -6366,9 +6373,11 @@ static int s2io_change_mtu(struct net_device *dev, int new_mtu)
 	if (netif_running(dev)) {
 		s2io_card_down(sp);
 		netif_stop_queue(dev);
-		if (s2io_card_up(sp)) {
+		ret = s2io_card_up(sp);
+		if (ret) {
 			DBG_PRINT(ERR_DBG, "%s: Device bring up failed\n",
 				  __FUNCTION__);
+			return ret;
 		}
 		if (netif_queue_stopped(dev))
 			netif_wake_queue(dev);
@@ -6379,7 +6388,7 @@ static int s2io_change_mtu(struct net_device *dev, int new_mtu)
 		writeq(vBIT(val64, 2, 14), &bar0->rmac_max_pyld_len);
 	}
 
-	return 0;
+	return ret;
 }
 
 /**
@@ -6777,6 +6786,9 @@ static void do_s2io_card_down(struct s2io_nic * sp, int do_io)
 	unsigned long flags;
 	register u64 val64 = 0;
 
+	if (!is_s2io_card_up(sp))
+		return;
+
 	del_timer_sync(&sp->alarm_timer);
 	/* If s2io_set_link task is executing, wait till it completes. */
 	while (test_and_set_bit(__S2IO_STATE_LINK_TASK, &(sp->state))) {
@@ -6850,11 +6862,13 @@ static int s2io_card_up(struct s2io_nic * sp)
 	u16 interruptible;
 
 	/* Initialize the H/W I/O registers */
-	if (init_nic(sp) != 0) {
+	ret = init_nic(sp);
+	if (ret != 0) {
 		DBG_PRINT(ERR_DBG, "%s: H/W initialization failed\n",
 			  dev->name);
-		s2io_reset(sp);
-		return -ENODEV;
+		if (ret != -EIO)
+			s2io_reset(sp);
+		return ret;
 	}
 
 	/*
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 6d62250..186eb8e 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -44,7 +44,7 @@
 #include "skge.h"
 
 #define DRV_NAME		"skge"
-#define DRV_VERSION		"1.12"
+#define DRV_VERSION		"1.13"
 #define PFX			DRV_NAME " "
 
 #define DEFAULT_TX_RING_SIZE	128
@@ -1095,16 +1095,9 @@ static void xm_link_down(struct skge_hw *hw, int port)
 {
 	struct net_device *dev = hw->dev[port];
 	struct skge_port *skge = netdev_priv(dev);
-	u16 cmd = xm_read16(hw, port, XM_MMU_CMD);
 
 	xm_write16(hw, port, XM_IMSK, XM_IMSK_DISABLE);
 
-	cmd &= ~(XM_MMU_ENA_RX | XM_MMU_ENA_TX);
-	xm_write16(hw, port, XM_MMU_CMD, cmd);
-
-	/* dummy read to ensure writing */
-	xm_read16(hw, port, XM_MMU_CMD);
-
 	if (netif_carrier_ok(dev))
 		skge_link_down(skge);
 }
@@ -1194,6 +1187,7 @@ static void genesis_init(struct skge_hw *hw)
 static void genesis_reset(struct skge_hw *hw, int port)
 {
 	const u8 zero[8]  = { 0 };
+	u32 reg;
 
 	skge_write8(hw, SK_REG(port, GMAC_IRQ_MSK), 0);
 
@@ -1209,6 +1203,11 @@ static void genesis_reset(struct skge_hw *hw, int port)
 		xm_write16(hw, port, PHY_BCOM_INT_MASK, 0xffff);
 
 	xm_outhash(hw, port, XM_HSM, zero);
+
+	/* Flush TX and RX fifo */
+	reg = xm_read32(hw, port, XM_MODE);
+	xm_write32(hw, port, XM_MODE, reg | XM_MD_FTF);
+	xm_write32(hw, port, XM_MODE, reg | XM_MD_FRF);
 }
 
 
@@ -1634,15 +1633,14 @@ static void genesis_mac_init(struct skge_hw *hw, int port)
 	}
 	xm_write16(hw, port, XM_RX_CMD, r);
 
-
 	/* We want short frames padded to 60 bytes. */
 	xm_write16(hw, port, XM_TX_CMD, XM_TX_AUTO_PAD);
 
-	/*
-	 * Bump up the transmit threshold. This helps hold off transmit
-	 * underruns when we're blasting traffic from both ports at once.
-	 */
-	xm_write16(hw, port, XM_TX_THR, 512);
+	/* Increase threshold for jumbo frames on dual port */
+	if (hw->ports > 1 && jumbo)
+		xm_write16(hw, port, XM_TX_THR, 1020);
+	else
+		xm_write16(hw, port, XM_TX_THR, 512);
 
 	/*
 	 * Enable the reception of all error frames. This is is
@@ -1713,7 +1711,13 @@ static void genesis_stop(struct skge_port *skge)
 {
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
-	u32 reg;
+	unsigned retries = 1000;
+	u16 cmd;
+
+ 	/* Disable Tx and Rx */
+	cmd = xm_read16(hw, port, XM_MMU_CMD);
+	cmd &= ~(XM_MMU_ENA_RX | XM_MMU_ENA_TX);
+	xm_write16(hw, port, XM_MMU_CMD, cmd);
 
 	genesis_reset(hw, port);
 
@@ -1721,20 +1725,17 @@ static void genesis_stop(struct skge_port *skge)
 	skge_write16(hw, B3_PA_CTRL,
 		     port == 0 ? PA_CLR_TO_TX1 : PA_CLR_TO_TX2);
 
-	/*
-	 * If the transfer sticks at the MAC the STOP command will not
-	 * terminate if we don't flush the XMAC's transmit FIFO !
-	 */
-	xm_write32(hw, port, XM_MODE,
-			xm_read32(hw, port, XM_MODE)|XM_MD_FTF);
-
-
 	/* Reset the MAC */
-	skge_write16(hw, SK_REG(port, TX_MFF_CTRL1), MFF_SET_MAC_RST);
+	skge_write16(hw, SK_REG(port, TX_MFF_CTRL1), MFF_CLR_MAC_RST);
+	do {
+		skge_write16(hw, SK_REG(port, TX_MFF_CTRL1), MFF_SET_MAC_RST);
+		if (!(skge_read16(hw, SK_REG(port, TX_MFF_CTRL1)) & MFF_SET_MAC_RST))
+			break;
+	} while (--retries > 0);
 
 	/* For external PHYs there must be special handling */
 	if (hw->phy_type != SK_PHY_XMAC) {
-		reg = skge_read32(hw, B2_GP_IO);
+		u32 reg = skge_read32(hw, B2_GP_IO);
 		if (port == 0) {
 			reg |= GP_DIR_0;
 			reg &= ~GP_IO_0;
@@ -1801,11 +1802,6 @@ static void genesis_mac_intr(struct skge_hw *hw, int port)
 		xm_write32(hw, port, XM_MODE, XM_MD_FTF);
 		++dev->stats.tx_fifo_errors;
 	}
-
-	if (status & XM_IS_RXF_OV) {
-		xm_write32(hw, port, XM_MODE, XM_MD_FRF);
-		++dev->stats.rx_fifo_errors;
-	}
 }
 
 static void genesis_link_up(struct skge_port *skge)
@@ -1862,9 +1858,9 @@ static void genesis_link_up(struct skge_port *skge)
 
 	xm_write32(hw, port, XM_MODE, mode);
 
-	/* Turn on detection of Tx underrun, Rx overrun */
+	/* Turn on detection of Tx underrun */
 	msk = xm_read16(hw, port, XM_IMSK);
-	msk &= ~(XM_IS_RXF_OV | XM_IS_TXF_UR);
+	msk &= ~XM_IS_TXF_UR;
 	xm_write16(hw, port, XM_IMSK, msk);
 
 	xm_read16(hw, port, XM_ISRC);
@@ -2194,9 +2190,12 @@ static void yukon_mac_init(struct skge_hw *hw, int port)
 			 TX_JAM_IPG_VAL(TX_JAM_IPG_DEF) |
 			 TX_IPG_JAM_DATA(TX_IPG_JAM_DEF));
 
-	/* serial mode register */
-	reg = GM_SMOD_VLAN_ENA | IPG_DATA_VAL(IPG_DATA_DEF);
-	if (hw->dev[port]->mtu > 1500)
+	/* configure the Serial Mode Register */
+	reg = DATA_BLIND_VAL(DATA_BLIND_DEF)
+		| GM_SMOD_VLAN_ENA
+		| IPG_DATA_VAL(IPG_DATA_DEF);
+
+	if (hw->dev[port]->mtu > ETH_DATA_LEN)
 		reg |= GM_SMOD_JUMBO_ENA;
 
 	gma_write16(hw, port, GM_SERIAL_MODE, reg);
@@ -2619,8 +2618,8 @@ static int skge_up(struct net_device *dev)
 		yukon_mac_init(hw, port);
 	spin_unlock_bh(&hw->phy_lock);
 
-	/* Configure RAMbuffers */
-	chunk = hw->ram_size / ((hw->ports + 1)*2);
+	/* Configure RAMbuffers - equally between ports and tx/rx */
+	chunk = (hw->ram_size  - hw->ram_offset) / (hw->ports * 2);
 	ram_addr = hw->ram_offset + 2 * chunk * port;
 
 	skge_ramset(hw, rxqaddr[port], ram_addr, chunk);
@@ -2897,11 +2896,7 @@ static void skge_tx_timeout(struct net_device *dev)
 
 static int skge_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct skge_port *skge = netdev_priv(dev);
-	struct skge_hw *hw = skge->hw;
-	int port = skge->port;
 	int err;
-	u16 ctl, reg;
 
 	if (new_mtu < ETH_ZLEN || new_mtu > ETH_JUMBO_MTU)
 		return -EINVAL;
@@ -2911,40 +2906,13 @@ static int skge_change_mtu(struct net_device *dev, int new_mtu)
 		return 0;
 	}
 
-	skge_write32(hw, B0_IMSK, 0);
-	dev->trans_start = jiffies;	/* prevent tx timeout */
-	netif_stop_queue(dev);
-	napi_disable(&skge->napi);
-
-	ctl = gma_read16(hw, port, GM_GP_CTRL);
-	gma_write16(hw, port, GM_GP_CTRL, ctl & ~GM_GPCR_RX_ENA);
-
-	skge_rx_clean(skge);
-	skge_rx_stop(hw, port);
+	skge_down(dev);
 
 	dev->mtu = new_mtu;
 
-	reg = GM_SMOD_VLAN_ENA | IPG_DATA_VAL(IPG_DATA_DEF);
-	if (new_mtu > 1500)
-		reg |= GM_SMOD_JUMBO_ENA;
-	gma_write16(hw, port, GM_SERIAL_MODE, reg);
-
-	skge_write8(hw, RB_ADDR(rxqaddr[port], RB_CTRL), RB_ENA_OP_MD);
-
-	err = skge_rx_fill(dev);
-	wmb();
-	if (!err)
-		skge_write8(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_START | CSR_IRQ_CL_F);
-	skge_write32(hw, B0_IMSK, hw->intr_mask);
-
+	err = skge_up(dev);
 	if (err)
 		dev_close(dev);
-	else {
-		gma_write16(hw, port, GM_GP_CTRL, ctl);
-
-		napi_enable(&skge->napi);
-		netif_wake_queue(dev);
-	}
 
 	return err;
 }
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index a2070db..3d1dfc9 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -31,7 +31,6 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/pci.h>
-#include <linux/aer.h>
 #include <linux/ip.h>
 #include <net/ip.h>
 #include <linux/tcp.h>
@@ -240,22 +239,21 @@ static void sky2_power_on(struct sky2_hw *hw)
 		sky2_write8(hw, B2_Y2_CLK_GATE, 0);
 
 	if (hw->flags & SKY2_HW_ADV_POWER_CTL) {
-		struct pci_dev *pdev = hw->pdev;
 		u32 reg;
 
-		pci_write_config_dword(pdev, PCI_DEV_REG3, 0);
+		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
 
-		pci_read_config_dword(pdev, PCI_DEV_REG4, &reg);
+		reg = sky2_pci_read32(hw, PCI_DEV_REG4);
 		/* set all bits to 0 except bits 15..12 and 8 */
 		reg &= P_ASPM_CONTROL_MSK;
-		pci_write_config_dword(pdev, PCI_DEV_REG4, reg);
+		sky2_pci_write32(hw, PCI_DEV_REG4, reg);
 
-		pci_read_config_dword(pdev, PCI_DEV_REG5, &reg);
+		reg = sky2_pci_read32(hw, PCI_DEV_REG5);
 		/* set all bits to 0 except bits 28 & 27 */
 		reg &= P_CTL_TIM_VMAIN_AV_MSK;
-		pci_write_config_dword(pdev, PCI_DEV_REG5, reg);
+		sky2_pci_write32(hw, PCI_DEV_REG5, reg);
 
-		pci_write_config_dword(pdev, PCI_CFG_REG_1, 0);
+		sky2_pci_write32(hw, PCI_CFG_REG_1, 0);
 
 		/* Enable workaround for dev 4.107 on Yukon-Ultra & Extreme */
 		reg = sky2_read32(hw, B2_GP_IO);
@@ -619,12 +617,11 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 
 static void sky2_phy_power(struct sky2_hw *hw, unsigned port, int onoff)
 {
-	struct pci_dev *pdev = hw->pdev;
 	u32 reg1;
 	static const u32 phy_power[] = { PCI_Y2_PHY1_POWD, PCI_Y2_PHY2_POWD };
 	static const u32 coma_mode[] = { PCI_Y2_PHY1_COMA, PCI_Y2_PHY2_COMA };
 
-	pci_read_config_dword(pdev, PCI_DEV_REG1, &reg1);
+	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
 	/* Turn on/off phy power saving */
 	if (onoff)
 		reg1 &= ~phy_power[port];
@@ -634,8 +631,8 @@ static void sky2_phy_power(struct sky2_hw *hw, unsigned port, int onoff)
 	if (onoff && hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
 		reg1 |= coma_mode[port];
 
-	pci_write_config_dword(pdev, PCI_DEV_REG1, reg1);
-	pci_read_config_dword(pdev, PCI_DEV_REG1, &reg1);
+	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
+	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
 
 	udelay(100);
 }
@@ -704,9 +701,9 @@ static void sky2_wol_init(struct sky2_port *sky2)
 	sky2_write16(hw, WOL_REGS(port, WOL_CTRL_STAT), ctrl);
 
 	/* Turn on legacy PCI-Express PME mode */
-	pci_read_config_dword(hw->pdev, PCI_DEV_REG1, &reg1);
+	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
 	reg1 |= PCI_Y2_PME_LEGACY;
-	pci_write_config_dword(hw->pdev, PCI_DEV_REG1, reg1);
+	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
 
 	/* block receiver */
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
@@ -848,6 +845,13 @@ static void sky2_mac_init(struct sky2_hw *hw, unsigned port)
 		sky2_set_tx_stfwd(hw, port);
 	}
 
+	if (hw->chip_id == CHIP_ID_YUKON_FE_P &&
+	    hw->chip_rev == CHIP_REV_YU_FE2_A0) {
+		/* disable dynamic watermark */
+		reg = sky2_read16(hw, SK_REG(port, TX_GMF_EA));
+		reg &= ~TX_DYN_WM_ENA;
+		sky2_write16(hw, SK_REG(port, TX_GMF_EA), reg);
+	}
 }
 
 /* Assign Ram Buffer allocation to queue */
@@ -1320,15 +1324,12 @@ static int sky2_up(struct net_device *dev)
 	 */
 	if (otherdev && netif_running(otherdev) &&
  	    (cap = pci_find_capability(hw->pdev, PCI_CAP_ID_PCIX))) {
- 		struct sky2_port *osky2 = netdev_priv(otherdev);
  		u16 cmd;
 
-		pci_read_config_word(hw->pdev, cap + PCI_X_CMD, &cmd);
+		cmd = sky2_pci_read16(hw, cap + PCI_X_CMD);
  		cmd &= ~PCI_X_CMD_MAX_SPLIT;
-		pci_write_config_word(hw->pdev, cap + PCI_X_CMD, cmd);
+ 		sky2_pci_write16(hw, cap + PCI_X_CMD, cmd);
 
- 		sky2->rx_csum = 0;
- 		osky2->rx_csum = 0;
  	}
 
 	if (netif_msg_ifup(sky2))
@@ -2426,37 +2427,26 @@ static void sky2_hw_intr(struct sky2_hw *hw)
 	if (status & (Y2_IS_MST_ERR | Y2_IS_IRQ_STAT)) {
 		u16 pci_err;
 
-		pci_read_config_word(pdev, PCI_STATUS, &pci_err);
+		pci_err = sky2_pci_read16(hw, PCI_STATUS);
 		if (net_ratelimit())
 			dev_err(&pdev->dev, "PCI hardware error (0x%x)\n",
 			        pci_err);
 
-		pci_write_config_word(pdev, PCI_STATUS,
+		sky2_pci_write16(hw, PCI_STATUS,
 				      pci_err | PCI_STATUS_ERROR_BITS);
 	}
 
 	if (status & Y2_IS_PCI_EXP) {
 		/* PCI-Express uncorrectable Error occurred */
-		int aer = pci_find_aer_capability(hw->pdev);
 		u32 err;
 
-		if (aer) {
-			pci_read_config_dword(pdev, aer + PCI_ERR_UNCOR_STATUS,
-					      &err);
-			pci_cleanup_aer_uncorrect_error_status(pdev);
-		} else {
-			/* Either AER not configured, or not working
-			 * because of bad MMCONFIG, so just do recover
-			 * manually.
-			 */
-			err = sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
-			sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
-				     0xfffffffful);
-		}
-
+		err = sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
+		sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
+			     0xfffffffful);
 		if (net_ratelimit())
 			dev_err(&pdev->dev, "PCI Express error (0x%x)\n", err);
 
+		sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
 	}
 
 	if (status & Y2_HWE_L1_MASK)
@@ -2703,13 +2693,10 @@ static inline u32 sky2_clk2us(const struct sky2_hw *hw, u32 clk)
 
 static int __devinit sky2_init(struct sky2_hw *hw)
 {
-	int rc;
 	u8 t8;
 
 	/* Enable all clocks and check for bad PCI access */
-	rc = pci_write_config_dword(hw->pdev, PCI_DEV_REG3, 0);
-	if (rc)
-		return rc;
+	sky2_pci_write32(hw, PCI_DEV_REG3, 0);
 
 	sky2_write8(hw, B0_CTST, CS_RST_CLR);
 
@@ -2806,32 +2793,21 @@ static void sky2_reset(struct sky2_hw *hw)
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 
 	/* clear PCI errors, if any */
-	pci_read_config_word(pdev, PCI_STATUS, &status);
+	status = sky2_pci_read16(hw, PCI_STATUS);
 	status |= PCI_STATUS_ERROR_BITS;
-	pci_write_config_word(pdev, PCI_STATUS, status);
+	sky2_pci_write16(hw, PCI_STATUS, status);
 
 	sky2_write8(hw, B0_CTST, CS_MRST_CLR);
 
 	cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
 	if (cap) {
-		if (pci_find_aer_capability(pdev)) {
-			/* Check for advanced error reporting */
-			pci_cleanup_aer_uncorrect_error_status(pdev);
-			pci_cleanup_aer_correct_error_status(pdev);
-		} else {
-			dev_warn(&pdev->dev,
-				"PCI Express Advanced Error Reporting"
-				" not configured or MMCONFIG problem?\n");
-
-			sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
-				     0xfffffffful);
-		}
+		sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
+			     0xfffffffful);
 
 		/* If error bit is stuck on ignore it */
 		if (sky2_read32(hw, B0_HWE_ISRC) & Y2_IS_PCI_EXP)
 			dev_info(&pdev->dev, "ignoring stuck error report bit\n");
-
-		else if (pci_enable_pcie_error_reporting(pdev))
+		else
 			hwe_mask |= Y2_IS_PCI_EXP;
 	}
 
@@ -3672,32 +3648,33 @@ static int sky2_set_tso(struct net_device *dev, u32 data)
 static int sky2_get_eeprom_len(struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
+	struct sky2_hw *hw = sky2->hw;
 	u16 reg2;
 
-	pci_read_config_word(sky2->hw->pdev, PCI_DEV_REG2, &reg2);
+	reg2 = sky2_pci_read16(hw, PCI_DEV_REG2);
 	return 1 << ( ((reg2 & PCI_VPD_ROM_SZ) >> 14) + 8);
 }
 
-static u32 sky2_vpd_read(struct pci_dev *pdev, int cap, u16 offset)
+static u32 sky2_vpd_read(struct sky2_hw *hw, int cap, u16 offset)
 {
 	u32 val;
 
-	pci_write_config_word(pdev, cap + PCI_VPD_ADDR, offset);
+	sky2_pci_write16(hw, cap + PCI_VPD_ADDR, offset);
 
 	do {
-		pci_read_config_word(pdev, cap + PCI_VPD_ADDR, &offset);
+		offset = sky2_pci_read16(hw, cap + PCI_VPD_ADDR);
 	} while (!(offset & PCI_VPD_ADDR_F));
 
-	pci_read_config_dword(pdev, cap + PCI_VPD_DATA, &val);
+	val = sky2_pci_read32(hw, cap + PCI_VPD_DATA);
 	return val;
 }
 
-static void sky2_vpd_write(struct pci_dev *pdev, int cap, u16 offset, u32 val)
+static void sky2_vpd_write(struct sky2_hw *hw, int cap, u16 offset, u32 val)
 {
-	pci_write_config_word(pdev, cap + PCI_VPD_DATA, val);
-	pci_write_config_dword(pdev, cap + PCI_VPD_ADDR, offset | PCI_VPD_ADDR_F);
+	sky2_pci_write16(hw, cap + PCI_VPD_DATA, val);
+	sky2_pci_write32(hw, cap + PCI_VPD_ADDR, offset | PCI_VPD_ADDR_F);
 	do {
-		pci_read_config_word(pdev, cap + PCI_VPD_ADDR, &offset);
+		offset = sky2_pci_read16(hw, cap + PCI_VPD_ADDR);
 	} while (offset & PCI_VPD_ADDR_F);
 }
 
@@ -3715,7 +3692,7 @@ static int sky2_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom
 	eeprom->magic = SKY2_EEPROM_MAGIC;
 
 	while (length > 0) {
-		u32 val = sky2_vpd_read(sky2->hw->pdev, cap, offset);
+		u32 val = sky2_vpd_read(sky2->hw, cap, offset);
 		int n = min_t(int, length, sizeof(val));
 
 		memcpy(data, &val, n);
@@ -3745,10 +3722,10 @@ static int sky2_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom
 		int n = min_t(int, length, sizeof(val));
 
 		if (n < sizeof(val))
-			val = sky2_vpd_read(sky2->hw->pdev, cap, offset);
+			val = sky2_vpd_read(sky2->hw, cap, offset);
 		memcpy(&val, data, n);
 
-		sky2_vpd_write(sky2->hw->pdev, cap, offset, val);
+		sky2_vpd_write(sky2->hw, cap, offset, val);
 
 		length -= n;
 		data += n;
@@ -4013,7 +3990,7 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 	sky2->duplex = -1;
 	sky2->speed = -1;
 	sky2->advertising = sky2_supported_modes(hw);
-	sky2->rx_csum = 1;
+	sky2->rx_csum = (hw->chip_id != CHIP_ID_YUKON_XL);
 	sky2->wol = wol;
 
 	spin_lock_init(&sky2->phy_lock);
@@ -4184,9 +4161,9 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 	 */
 	{
 		u32 reg;
-		pci_read_config_dword(pdev,PCI_DEV_REG2, &reg);
+		reg = sky2_pci_read32(hw, PCI_DEV_REG2);
 		reg &= ~PCI_REV_DESC;
-		pci_write_config_dword(pdev, PCI_DEV_REG2, reg);
+		sky2_pci_write32(hw, PCI_DEV_REG2, reg);
 	}
 #endif
 
@@ -4377,7 +4354,7 @@ static int sky2_resume(struct pci_dev *pdev)
 	if (hw->chip_id == CHIP_ID_YUKON_EX ||
 	    hw->chip_id == CHIP_ID_YUKON_EC_U ||
 	    hw->chip_id == CHIP_ID_YUKON_FE_P)
-		pci_write_config_dword(pdev, PCI_DEV_REG3, 0);
+		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
 
 	sky2_reset(hw);
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 69525fd..bc646a4 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -2128,4 +2128,25 @@ static inline void gma_set_addr(struct sky2_hw *hw, unsigned port, unsigned reg,
 	gma_write16(hw, port, reg+4,(u16) addr[2] | ((u16) addr[3] << 8));
 	gma_write16(hw, port, reg+8,(u16) addr[4] | ((u16) addr[5] << 8));
 }
+
+/* PCI config space access */
+static inline u32 sky2_pci_read32(const struct sky2_hw *hw, unsigned reg)
+{
+	return sky2_read32(hw, Y2_CFG_SPC + reg);
+}
+
+static inline u16 sky2_pci_read16(const struct sky2_hw *hw, unsigned reg)
+{
+	return sky2_read16(hw, Y2_CFG_SPC + reg);
+}
+
+static inline void sky2_pci_write32(struct sky2_hw *hw, unsigned reg, u32 val)
+{
+	sky2_write32(hw, Y2_CFG_SPC + reg, val);
+}
+
+static inline void sky2_pci_write16(struct sky2_hw *hw, unsigned reg, u16 val)
+{
+	sky2_write16(hw, Y2_CFG_SPC + reg, val);
+}
 #endif
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index dd18af0..1a3d80b 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -428,7 +428,6 @@ static inline void smc911x_drop_pkt(struct net_device *dev)
  */
 static inline void	 smc911x_rcv(struct net_device *dev)
 {
-	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	unsigned int pkt_len, status;
 	struct sk_buff *skb;
@@ -473,6 +472,7 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 		skb_put(skb,pkt_len-4);
 #ifdef SMC_USE_DMA
 		{
+		struct smc911x_local *lp = netdev_priv(dev);
 		unsigned int fifo;
 		/* Lower the FIFO threshold if possible */
 		fifo = SMC_GET_FIFO_INT();
@@ -1379,13 +1379,6 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 	unsigned int multicast_table[2];
 	unsigned int mcr, update_multicast = 0;
 	unsigned long flags;
-	/* table for flipping the order of 5 bits */
-	static const unsigned char invert5[] =
-		{0x00, 0x10, 0x08, 0x18, 0x04, 0x14, 0x0C, 0x1C,
-		 0x02, 0x12, 0x0A, 0x1A, 0x06, 0x16, 0x0E, 0x1E,
-		 0x01, 0x11, 0x09, 0x19, 0x05, 0x15, 0x0D, 0x1D,
-		 0x03, 0x13, 0x0B, 0x1B, 0x07, 0x17, 0x0F, 0x1F};
-
 
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
@@ -1432,7 +1425,7 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 
 		cur_addr = dev->mc_list;
 		for (i = 0; i < dev->mc_count; i++, cur_addr = cur_addr->next) {
-			int position;
+			u32 position;
 
 			/* do we have a pointer here? */
 			if (!cur_addr)
@@ -1442,12 +1435,10 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 			if (!(*cur_addr->dmi_addr & 1))
 				 continue;
 
-			/* only use the low order bits */
-			position = crc32_le(~0, cur_addr->dmi_addr, 6) & 0x3f;
+			/* upper 6 bits are used as hash index */
+			position = ether_crc(ETH_ALEN, cur_addr->dmi_addr)>>26;
 
-			/* do some messy swapping to put the bit in the right spot */
-			multicast_table[invert5[position&0x1F]&0x1] |=
-				(1<<invert5[(position>>1)&0x1F]);
+			multicast_table[position>>5] |= 1 << (position&0x1f);
 		}
 
 		/* be sure I get rid of flags I might have set */
diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index 16a0edc..d04e4fa 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -37,7 +37,7 @@
   #define SMC_USE_16BIT		0
   #define SMC_USE_32BIT		1
   #define SMC_IRQ_SENSE		IRQF_TRIGGER_FALLING
-#elif CONFIG_SH_MAGIC_PANEL_R2
+#elif defined(CONFIG_SH_MAGIC_PANEL_R2)
   #define SMC_USE_SH_DMA	0
   #define SMC_USE_16BIT		0
   #define SMC_USE_32BIT		1
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index db34e1e..07b7f71 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -55,7 +55,7 @@
 #define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
 #define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
 
-#elif defined(CONFIG_BFIN)
+#elif defined(CONFIG_BLACKFIN)
 
 #define SMC_IRQ_FLAGS		IRQF_TRIGGER_HIGH
 #define RPC_LSA_DEFAULT		RPC_LED_100_10
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index ca90566..b4891ca 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -2118,8 +2118,8 @@ static int dmfe_suspend(struct pci_dev *pci_dev, pm_message_t state)
 	pci_enable_wake(pci_dev, PCI_D3cold, 1);
 
 	/* Power down device*/
-	pci_set_power_state(pci_dev, pci_choose_state (pci_dev,state));
 	pci_save_state(pci_dev);
+	pci_set_power_state(pci_dev, pci_choose_state (pci_dev, state));
 
 	return 0;
 }
@@ -2129,8 +2129,8 @@ static int dmfe_resume(struct pci_dev *pci_dev)
 	struct net_device *dev = pci_get_drvdata(pci_dev);
 	u32 tmp;
 
-	pci_restore_state(pci_dev);
 	pci_set_power_state(pci_dev, PCI_D0);
+	pci_restore_state(pci_dev);
 
 	/* Re-initilize DM910X board */
 	dmfe_init_dm910x(dev);
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index a3ff270..7f68990 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1460,6 +1460,8 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 	if ((ugeth->phy_interface == PHY_INTERFACE_MODE_RMII) ||
 	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII) ||
 	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_ID) ||
+	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
+	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID) ||
 	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RTBI)) {
 		upsmr |= UPSMR_RPM;
 		switch (ugeth->max_speed) {
@@ -1557,6 +1559,8 @@ static void adjust_link(struct net_device *dev)
 				if ((ugeth->phy_interface == PHY_INTERFACE_MODE_RMII) ||
 				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII) ||
 				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_ID) ||
+				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
+				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID) ||
 				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RTBI)) {
 					if (phydev->speed == SPEED_10)
 						upsmr |= UPSMR_R10M;
@@ -3795,6 +3799,10 @@ static phy_interface_t to_phy_interface(const char *phy_connection_type)
 		return PHY_INTERFACE_MODE_RGMII;
 	if (strcasecmp(phy_connection_type, "rgmii-id") == 0)
 		return PHY_INTERFACE_MODE_RGMII_ID;
+	if (strcasecmp(phy_connection_type, "rgmii-txid") == 0)
+		return PHY_INTERFACE_MODE_RGMII_TXID;
+	if (strcasecmp(phy_connection_type, "rgmii-rxid") == 0)
+		return PHY_INTERFACE_MODE_RGMII_RXID;
 	if (strcasecmp(phy_connection_type, "rtbi") == 0)
 		return PHY_INTERFACE_MODE_RTBI;
 
@@ -3889,6 +3897,8 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		case PHY_INTERFACE_MODE_GMII:
 		case PHY_INTERFACE_MODE_RGMII:
 		case PHY_INTERFACE_MODE_RGMII_ID:
+		case PHY_INTERFACE_MODE_RGMII_RXID:
+		case PHY_INTERFACE_MODE_RGMII_TXID:
 		case PHY_INTERFACE_MODE_TBI:
 		case PHY_INTERFACE_MODE_RTBI:
 			max_speed = SPEED_1000;
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 2c68573..1ffdd10 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -94,7 +94,7 @@ static void dm_write_async_callback(struct urb *urb)
 	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
 
 	if (urb->status < 0)
-		printk(KERN_DEBUG "dm_write_async_callback() failed with %d",
+		printk(KERN_DEBUG "dm_write_async_callback() failed with %d\n",
 		       urb->status);
 
 	kfree(req);
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 450e29d..35cd65d 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1242,6 +1242,9 @@ static int velocity_rx_refill(struct velocity_info *vptr)
 static int velocity_init_rd_ring(struct velocity_info *vptr)
 {
 	int ret;
+	int mtu = vptr->dev->mtu;
+
+	vptr->rx_buf_sz = (mtu <= ETH_DATA_LEN) ? PKT_BUF_SZ : mtu + 32;
 
 	vptr->rd_info = kcalloc(vptr->options.numrx,
 				sizeof(struct velocity_rd_info), GFP_KERNEL);
@@ -1898,8 +1901,6 @@ static int velocity_open(struct net_device *dev)
 	struct velocity_info *vptr = netdev_priv(dev);
 	int ret;
 
-	vptr->rx_buf_sz = (dev->mtu <= 1504 ? PKT_BUF_SZ : dev->mtu + 32);
-
 	ret = velocity_init_rings(vptr);
 	if (ret < 0)
 		goto out;
@@ -1978,12 +1979,6 @@ static int velocity_change_mtu(struct net_device *dev, int new_mtu)
 		velocity_free_rd_ring(vptr);
 
 		dev->mtu = new_mtu;
-		if (new_mtu > 8192)
-			vptr->rx_buf_sz = 9 * 1024;
-		else if (new_mtu > 4096)
-			vptr->rx_buf_sz = 8192;
-		else
-			vptr->rx_buf_sz = 4 * 1024;
 
 		ret = velocity_init_rd_ring(vptr);
 		if (ret < 0)
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 2b17c1d..b45eecc 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -1566,7 +1566,7 @@ static void b43_release_firmware(struct b43_wldev *dev)
 static void b43_print_fw_helptext(struct b43_wl *wl)
 {
 	b43err(wl, "You must go to "
-	       "http://linuxwireless.org/en/users/Drivers/bcm43xx#devicefirmware "
+	       "http://linuxwireless.org/en/users/Drivers/b43#devicefirmware "
 	       "and download the correct firmware (version 4).\n");
 }
 
diff --git a/drivers/net/wireless/b43/phy.c b/drivers/net/wireless/b43/phy.c
index 3d4ed64..7ff091e 100644
--- a/drivers/net/wireless/b43/phy.c
+++ b/drivers/net/wireless/b43/phy.c
@@ -2214,7 +2214,7 @@ int b43_phy_init_tssi2dbm_table(struct b43_wldev *dev)
 		}
 		dyn_tssi2dbm = kmalloc(64, GFP_KERNEL);
 		if (dyn_tssi2dbm == NULL) {
-			b43err(dev->wl, "Could not allocate memory"
+			b43err(dev->wl, "Could not allocate memory "
 			       "for tssi2dbm table\n");
 			return -ENOMEM;
 		}
diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index 8cb3dc4..83161d9 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -996,7 +996,7 @@ int b43legacy_dma_init(struct b43legacy_wldev *dev)
 
 	err = ssb_dma_set_mask(dev->dev, dmamask);
 	if (err) {
-#ifdef BCM43XX_PIO
+#ifdef CONFIG_B43LEGACY_PIO
 		b43legacywarn(dev->wl, "DMA for this device not supported. "
 			"Falling back to PIO\n");
 		dev->__using_pio = 1;
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index 3bde1e9..32d5e17 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -1419,7 +1419,7 @@ static void b43legacy_release_firmware(struct b43legacy_wldev *dev)
 static void b43legacy_print_fw_helptext(struct b43legacy_wl *wl)
 {
 	b43legacyerr(wl, "You must go to http://linuxwireless.org/en/users/"
-		     "Drivers/bcm43xx#devicefirmware "
+		     "Drivers/b43#devicefirmware "
 		     "and download the correct firmware (version 3).\n");
 }
 
diff --git a/drivers/net/wireless/b43legacy/phy.c b/drivers/net/wireless/b43legacy/phy.c
index 22a4b3d..491e518 100644
--- a/drivers/net/wireless/b43legacy/phy.c
+++ b/drivers/net/wireless/b43legacy/phy.c
@@ -2020,7 +2020,7 @@ int b43legacy_phy_init_tssi2dbm_table(struct b43legacy_wldev *dev)
 			phy->idle_tssi = 62;
 		dyn_tssi2dbm = kmalloc(64, GFP_KERNEL);
 		if (dyn_tssi2dbm == NULL) {
-			b43legacyerr(dev->wl, "Could not allocate memory"
+			b43legacyerr(dev->wl, "Could not allocate memory "
 			       "for tssi2dbm table\n");
 			return -ENOMEM;
 		}
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
index b37f1e3..af3de33 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
@@ -2149,7 +2149,7 @@ int bcm43xx_phy_init_tssi2dbm_table(struct bcm43xx_private *bcm)
 		}
 		dyn_tssi2dbm = kmalloc(64, GFP_KERNEL);
 		if (dyn_tssi2dbm == NULL) {
-			printk(KERN_ERR PFX "Could not allocate memory"
+			printk(KERN_ERR PFX "Could not allocate memory "
 					    "for tssi2dbm table\n");
 			return -ENOMEM;
 		}
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 465da4f..4bdf237 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -2915,6 +2915,10 @@ static void iwl_set_rate(struct iwl_priv *priv)
 	int i;
 
 	hw = iwl_get_hw_mode(priv, priv->phymode);
+	if (!hw) {
+		IWL_ERROR("Failed to set rate: unable to get hw mode\n");
+		return;
+	}
 
 	priv->active_rate = 0;
 	priv->active_rate_basic = 0;
@@ -6936,13 +6940,10 @@ static int iwl_mac_add_interface(struct ieee80211_hw *hw,
 	DECLARE_MAC_BUF(mac);
 
 	IWL_DEBUG_MAC80211("enter: id %d, type %d\n", conf->if_id, conf->type);
-	if (conf->mac_addr)
-		IWL_DEBUG_MAC80211("enter: MAC %s\n",
-				   print_mac(mac, conf->mac_addr));
 
 	if (priv->interface_id) {
 		IWL_DEBUG_MAC80211("leave - interface_id != 0\n");
-		return 0;
+		return -EOPNOTSUPP;
 	}
 
 	spin_lock_irqsave(&priv->lock, flags);
@@ -6951,6 +6952,12 @@ static int iwl_mac_add_interface(struct ieee80211_hw *hw,
 	spin_unlock_irqrestore(&priv->lock, flags);
 
 	mutex_lock(&priv->mutex);
+
+	if (conf->mac_addr) {
+		IWL_DEBUG_MAC80211("Set: %s\n", print_mac(mac, conf->mac_addr));
+		memcpy(priv->mac_addr, conf->mac_addr, ETH_ALEN);
+	}
+
 	iwl_set_mode(priv, conf->type);
 
 	IWL_DEBUG_MAC80211("leave\n");
@@ -8270,6 +8277,7 @@ static void iwl_cancel_deferred_work(struct iwl_priv *priv)
 {
 	iwl_hw_cancel_deferred_work(priv);
 
+	cancel_delayed_work_sync(&priv->init_alive_start);
 	cancel_delayed_work(&priv->scan_check);
 	cancel_delayed_work(&priv->alive_start);
 	cancel_delayed_work(&priv->post_associate);
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index 9918780..8f85564 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -3003,6 +3003,10 @@ static void iwl_set_rate(struct iwl_priv *priv)
 	int i;
 
 	hw = iwl_get_hw_mode(priv, priv->phymode);
+	if (!hw) {
+		IWL_ERROR("Failed to set rate: unable to get hw mode\n");
+		return;
+	}
 
 	priv->active_rate = 0;
 	priv->active_rate_basic = 0;
@@ -7326,9 +7330,6 @@ static int iwl_mac_add_interface(struct ieee80211_hw *hw,
 	DECLARE_MAC_BUF(mac);
 
 	IWL_DEBUG_MAC80211("enter: id %d, type %d\n", conf->if_id, conf->type);
-	if (conf->mac_addr)
-		IWL_DEBUG_MAC80211("enter: MAC %s\n",
-				   print_mac(mac, conf->mac_addr));
 
 	if (priv->interface_id) {
 		IWL_DEBUG_MAC80211("leave - interface_id != 0\n");
@@ -7341,6 +7342,11 @@ static int iwl_mac_add_interface(struct ieee80211_hw *hw,
 	spin_unlock_irqrestore(&priv->lock, flags);
 
 	mutex_lock(&priv->mutex);
+
+	if (conf->mac_addr) {
+		IWL_DEBUG_MAC80211("Set %s\n", print_mac(mac, conf->mac_addr));
+		memcpy(priv->mac_addr, conf->mac_addr, ETH_ALEN);
+	}
 	iwl_set_mode(priv, conf->type);
 
 	IWL_DEBUG_MAC80211("leave\n");
@@ -8864,6 +8870,7 @@ static void iwl_cancel_deferred_work(struct iwl_priv *priv)
 {
 	iwl_hw_cancel_deferred_work(priv);
 
+	cancel_delayed_work_sync(&priv->init_alive_start);
 	cancel_delayed_work(&priv->scan_check);
 	cancel_delayed_work(&priv->alive_start);
 	cancel_delayed_work(&priv->post_associate);
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index ec89dab..ba4fc2b 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -170,7 +170,8 @@ static int if_cs_poll_while_fw_download(struct if_cs_card *card, uint addr, u8 r
 #define IF_CS_H_IC_TX_OVER		0x0001
 #define IF_CS_H_IC_RX_OVER		0x0002
 #define IF_CS_H_IC_DNLD_OVER		0x0004
-#define IF_CS_H_IC_HOST_EVENT		0x0008
+#define IF_CS_H_IC_POWER_DOWN		0x0008
+#define IF_CS_H_IC_HOST_EVENT		0x0010
 #define IF_CS_H_IC_MASK			0x001f
 
 #define IF_CS_H_INT_MASK		0x00000004
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 5ead083..1823b48 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -1165,8 +1165,6 @@ wlan_private *libertas_add_card(void *card, struct device *dmdev)
 #ifdef	WIRELESS_EXT
 	dev->wireless_handlers = (struct iw_handler_def *)&libertas_handler_def;
 #endif
-#define NETIF_F_DYNALLOC 16
-	dev->features |= NETIF_F_DYNALLOC;
 	dev->flags |= IFF_BROADCAST | IFF_MULTICAST;
 	dev->set_multicast_list = libertas_set_multicast_list;
 
@@ -1348,8 +1346,6 @@ int libertas_add_mesh(wlan_private *priv, struct device *dev)
 #ifdef	WIRELESS_EXT
 	mesh_dev->wireless_handlers = (struct iw_handler_def *)&mesh_handler_def;
 #endif
-#define NETIF_F_DYNALLOC 16
-
 	/* Register virtual mesh interface */
 	ret = register_netdev(mesh_dev);
 	if (ret) {
diff --git a/drivers/net/wireless/libertas/wext.c b/drivers/net/wireless/libertas/wext.c
index c6f5aa3..395b788 100644
--- a/drivers/net/wireless/libertas/wext.c
+++ b/drivers/net/wireless/libertas/wext.c
@@ -1528,7 +1528,7 @@ static int wlan_set_encodeext(struct net_device *dev,
 			&& (ext->key_len != KEY_LEN_WPA_TKIP))
 		    || ((alg == IW_ENCODE_ALG_CCMP)
 		        && (ext->key_len != KEY_LEN_WPA_AES))) {
-				lbs_deb_wext("invalid size %d for key of alg"
+				lbs_deb_wext("invalid size %d for key of alg "
 				       "type %d\n",
 				       ext->key_len,
 				       alg);
diff --git a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
index 2402cb8..d2fa079 100644
--- a/drivers/net/wireless/netwave_cs.c
+++ b/drivers/net/wireless/netwave_cs.c
@@ -806,7 +806,7 @@ static int netwave_pcmcia_config(struct pcmcia_device *link) {
     for (i = 0; i < 6; i++) 
 	dev->dev_addr[i] = readb(ramBase + NETWAVE_EREG_PA + i);
 
-    printk(KERN_INFO "%s: Netwave: port %#3lx, irq %d, mem %lx"
+    printk(KERN_INFO "%s: Netwave: port %#3lx, irq %d, mem %lx, "
 	   "id %c%c, hw_addr %s\n",
 	   dev->name, dev->base_addr, dev->irq,
 	   (u_long) ramBase,
diff --git a/drivers/net/wireless/p54usb.c b/drivers/net/wireless/p54usb.c
index 755482a..60d286e 100644
--- a/drivers/net/wireless/p54usb.c
+++ b/drivers/net/wireless/p54usb.c
@@ -308,7 +308,7 @@ static int p54u_read_eeprom(struct ieee80211_hw *dev)
 
 	buf = kmalloc(0x2020, GFP_KERNEL);
 	if (!buf) {
-		printk(KERN_ERR "prism54usb: cannot allocate memory for"
+		printk(KERN_ERR "prism54usb: cannot allocate memory for "
 		       "eeprom readback!\n");
 		return -ENOMEM;
 	}
diff --git a/drivers/s390/net/ctcmain.c b/drivers/s390/net/ctcmain.c
index 6bf3ebb..b3b6f65 100644
--- a/drivers/s390/net/ctcmain.c
+++ b/drivers/s390/net/ctcmain.c
@@ -2782,35 +2782,14 @@ ctc_probe_device(struct ccwgroup_device *cgdev)
 }
 
 /**
- * Initialize everything of the net device except the name and the
- * channel structs.
+ * Device setup function called by alloc_netdev().
+ *
+ * @param dev  Device to be setup.
  */
-static struct net_device *
-ctc_init_netdevice(struct net_device * dev, int alloc_device,
-		   struct ctc_priv *privptr)
+void ctc_init_netdevice(struct net_device * dev)
 {
-	if (!privptr)
-		return NULL;
-
 	DBF_TEXT(setup, 3, __FUNCTION__);
 
-	if (alloc_device) {
-		dev = kzalloc(sizeof(struct net_device), GFP_KERNEL);
-		if (!dev)
-			return NULL;
-	}
-
-	dev->priv = privptr;
-	privptr->fsm = init_fsm("ctcdev", dev_state_names,
-				dev_event_names, CTC_NR_DEV_STATES, CTC_NR_DEV_EVENTS,
-				dev_fsm, DEV_FSM_LEN, GFP_KERNEL);
-	if (privptr->fsm == NULL) {
-		if (alloc_device)
-			kfree(dev);
-		return NULL;
-	}
-	fsm_newstate(privptr->fsm, DEV_STATE_STOPPED);
-	fsm_settimer(privptr->fsm, &privptr->restart_timer);
 	if (dev->mtu == 0)
 		dev->mtu = CTC_BUFSIZE_DEFAULT - LL_HEADER_LENGTH - 2;
 	dev->hard_start_xmit = ctc_tx;
@@ -2823,7 +2802,7 @@ ctc_init_netdevice(struct net_device * dev, int alloc_device,
 	dev->type = ARPHRD_SLIP;
 	dev->tx_queue_len = 100;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP;
-	return dev;
+	SET_MODULE_OWNER(dev);
 }
 
 
@@ -2879,14 +2858,22 @@ ctc_new_device(struct ccwgroup_device *cgdev)
 		 	"ccw_device_set_online (cdev[1]) failed with ret = %d\n", ret);
 	}
 
-	dev = ctc_init_netdevice(NULL, 1, privptr);
-
+	dev = alloc_netdev(0, "ctc%d", ctc_init_netdevice);
 	if (!dev) {
 		ctc_pr_warn("ctc_init_netdevice failed\n");
 		goto out;
 	}
+	dev->priv = privptr;
 
-	strlcpy(dev->name, "ctc%d", IFNAMSIZ);
+	privptr->fsm = init_fsm("ctcdev", dev_state_names,
+			dev_event_names, CTC_NR_DEV_STATES, CTC_NR_DEV_EVENTS,
+			dev_fsm, DEV_FSM_LEN, GFP_KERNEL);
+	if (privptr->fsm == NULL) {
+		free_netdev(dev);
+		goto out;
+	}
+	fsm_newstate(privptr->fsm, DEV_STATE_STOPPED);
+	fsm_settimer(privptr->fsm, &privptr->restart_timer);
 
 	for (direction = READ; direction <= WRITE; direction++) {
 		privptr->channel[direction] =
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 1ee009e..111aa10 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1237,6 +1237,10 @@
 #define PCI_DEVICE_ID_NVIDIA_NVENET_33              0x0761
 #define PCI_DEVICE_ID_NVIDIA_NVENET_34              0x0762
 #define PCI_DEVICE_ID_NVIDIA_NVENET_35              0x0763
+#define PCI_DEVICE_ID_NVIDIA_NVENET_36              0x0AB0
+#define PCI_DEVICE_ID_NVIDIA_NVENET_37              0x0AB1
+#define PCI_DEVICE_ID_NVIDIA_NVENET_38              0x0AB2
+#define PCI_DEVICE_ID_NVIDIA_NVENET_39              0x0AB3
 
 #define PCI_VENDOR_ID_IMS		0x10e0
 #define PCI_DEVICE_ID_IMS_TT128		0x9128
diff --git a/include/linux/phy.h b/include/linux/phy.h
index f0742b6..e10763d 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -58,6 +58,8 @@ typedef enum {
 	PHY_INTERFACE_MODE_RMII,
 	PHY_INTERFACE_MODE_RGMII,
 	PHY_INTERFACE_MODE_RGMII_ID,
+	PHY_INTERFACE_MODE_RGMII_RXID,
+	PHY_INTERFACE_MODE_RGMII_TXID,
 	PHY_INTERFACE_MODE_RTBI
 } phy_interface_t;
 
