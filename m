From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 12/29] LMC: Get rid of the event logger.
Date: Sat, 31 Jul 2010 17:05:35 +0200
Message-ID: <1280588752-9340-12-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:37675 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756519Ab0GaPGS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:18 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Nobody will use this stuff anyway. It's much simpler to debug this with
printk() and friends.

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/debug.c |   18 ----------
 drivers/net/wan/lmc/debug.h |   33 ------------------
 drivers/net/wan/lmc/ioctl.h |    2 +-
 drivers/net/wan/lmc/lmc.h   |    4 --
 drivers/net/wan/lmc/main.c  |   79 ++++-------------------------------=
-------
 5 files changed, 9 insertions(+), 127 deletions(-)

diff --git a/drivers/net/wan/lmc/debug.c b/drivers/net/wan/lmc/debug.c
index e01b6e2..7c05cfe 100644
--- a/drivers/net/wan/lmc/debug.c
+++ b/drivers/net/wan/lmc/debug.c
@@ -3,24 +3,6 @@
 #include <linux/interrupt.h>
 #include "debug.h"
=20
-/*
- * Prints out len, max to 80 octets using printk, 20 per line
- */
-
-#ifdef DEBUG
-u32 lmcEventLogIndex;
-u32 lmcEventLogBuf[LMC_EVENTLOGSIZE * LMC_EVENTLOGARGS];
-
-void lmcEventLog(u32 EventNum, u32 arg2, u32 arg3)
-{
-	lmcEventLogBuf[lmcEventLogIndex++] =3D EventNum;
-	lmcEventLogBuf[lmcEventLogIndex++] =3D arg2;
-	lmcEventLogBuf[lmcEventLogIndex++] =3D arg3;
-	lmcEventLogBuf[lmcEventLogIndex++] =3D jiffies;
-	lmcEventLogIndex &=3D (LMC_EVENTLOGSIZE * LMC_EVENTLOGARGS) - 1;
-}
-#endif  /* DEBUG */
-
 void lmc_trace(struct net_device *dev, char *msg)
 {
 #ifdef LMC_TRACE
diff --git a/drivers/net/wan/lmc/debug.h b/drivers/net/wan/lmc/debug.h
index 6bee4ee..f026077 100644
--- a/drivers/net/wan/lmc/debug.h
+++ b/drivers/net/wan/lmc/debug.h
@@ -1,39 +1,6 @@
 #ifndef _LMC_DEBUG_H_
 #define _LMC_DEBUG_H_
=20
-/* Debug --- Event log definitions --- */
-/* EVENTLOGSIZE*EVENTLOGARGS needs to be a power of 2 */
-#define LMC_EVENTLOGSIZE 1024	/* number of events in eventlog */
-#define LMC_EVENTLOGARGS 4		/* number of args for each event */
-
-/* event indicators */
-#define LMC_EVENT_XMT           1
-#define LMC_EVENT_XMTEND        2
-#define LMC_EVENT_XMTINT        3
-#define LMC_EVENT_RCVINT        4
-#define LMC_EVENT_RCVEND        5
-#define LMC_EVENT_INT           6
-#define LMC_EVENT_XMTINTTMO     7
-#define LMC_EVENT_XMTPRCTMO     8
-#define LMC_EVENT_INTEND        9
-#define LMC_EVENT_RESET1       10
-#define LMC_EVENT_RESET2       11
-#define LMC_EVENT_FORCEDRESET  12
-#define LMC_EVENT_WATCHDOG     13
-#define LMC_EVENT_BADPKTSURGE  14
-#define LMC_EVENT_TBUSY0       15
-#define LMC_EVENT_TBUSY1       16
-
-
-#ifdef DEBUG
-extern u32 lmcEventLogIndex;
-extern u32 lmcEventLogBuf[LMC_EVENTLOGSIZE * LMC_EVENTLOGARGS];
-#define LMC_EVENT_LOG(x, y, z) lmcEventLog((x), (y), (z))
-#else
-#define LMC_EVENT_LOG(x, y, z)
-#endif /* end ifdef _DBG_EVENTLOG */
-
-void lmcEventLog(u32 EventNum, u32 arg2, u32 arg3);
 void lmc_trace(struct net_device *dev, char *msg);
=20
 #endif
diff --git a/drivers/net/wan/lmc/ioctl.h b/drivers/net/wan/lmc/ioctl.h
index 45b97e0..1b7820f 100644
--- a/drivers/net/wan/lmc/ioctl.h
+++ b/drivers/net/wan/lmc/ioctl.h
@@ -18,7 +18,7 @@
 #define LMCIOCSINFO         (SIOCDEVPRIVATE + 4) /* set state to user =
values */
 #define LMCIOCGETLMCSTATS   (SIOCDEVPRIVATE + 5)
 #define LMCIOCCLEARLMCSTATS (SIOCDEVPRIVATE + 6)
-#define LMCIOCDUMPEVENTLOG  (SIOCDEVPRIVATE + 7)
+#define LMCIOCDUMPEVENTLOG  (SIOCDEVPRIVATE + 7) /* now unused */
 #define LMCIOCGETXINFO      (SIOCDEVPRIVATE + 8)
 #define LMCIOCSETCIRCUIT    (SIOCDEVPRIVATE + 9)
 #define LMCIOCUNUSEDATM     (SIOCDEVPRIVATE + 10)
diff --git a/drivers/net/wan/lmc/lmc.h b/drivers/net/wan/lmc/lmc.h
index c3464b6..4ab8fe8 100644
--- a/drivers/net/wan/lmc/lmc.h
+++ b/drivers/net/wan/lmc/lmc.h
@@ -21,8 +21,4 @@ extern struct media lmc_ssi_media;
 extern struct media lmc_t1_media;
 extern struct media lmc_hssi_media;
=20
-#ifdef _DBG_EVENTLOG
-static void lmcEventLog(u32 EventNum, u32 arg2, u32 arg3);
-#endif
-
 #endif
diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index a19d63a..dc7e435 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -278,34 +278,16 @@ int lmc_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
=20
 		spin_lock_irqsave(&sc->lmc_lock, flags);
 		/* Reset driver and bring back to current state */
-		printk(KERN_DEBUG " REG16 before reset +%04x\n",
-		       lmc_mii_readreg(sc, 0, 16));
+		pr_debug("%s: REG16 before reset +%04x\n", dev->name,
+			 lmc_mii_readreg(sc, 0, 16));
 		lmc_running_reset(dev);
-		printk(KERN_DEBUG " REG16 after reset +%04x\n",
-		       lmc_mii_readreg(sc, 0, 16));
+		pr_debug("%s: REG16 after reset +%04x\n", dev->name,
+			 lmc_mii_readreg(sc, 0, 16));
=20
-		LMC_EVENT_LOG(LMC_EVENT_FORCEDRESET,
-			      LMC_CSR_READ(sc, csr_status),
-			      lmc_mii_readreg(sc, 0, 16));
 		spin_unlock_irqrestore(&sc->lmc_lock, flags);
 		ret =3D 0;
 		break;
=20
-#ifdef DEBUG
-	case LMCIOCDUMPEVENTLOG:
-		if (copy_to_user(ifr->ifr_data, &lmcEventLogIndex,
-				 sizeof(u32))) {
-			ret =3D -EFAULT;
-			break;
-		}
-		if (copy_to_user(ifr->ifr_data + sizeof(u32), lmcEventLogBuf,
-				 sizeof(lmcEventLogBuf)))
-			ret =3D -EFAULT;
-		else
-			ret =3D 0;
-
-		break;
-#endif /* end ifdef _DBG_EVENTLOG */
 	case LMCIOCT1CONTROL:
 		if (sc->lmc_cardtype !=3D LMC_CARDTYPE_T1) {
 			ret =3D -EOPNOTSUPP;
@@ -616,9 +598,6 @@ static void lmc_watchdog(unsigned long data)
 	if (sc->lmc_ok =3D=3D 0)
 		goto kick_timer;
=20
-	LMC_EVENT_LOG(LMC_EVENT_WATCHDOG, LMC_CSR_READ(sc, csr_status),
-		      lmc_mii_readreg(sc, 0, 16));
-
 	/* --- begin time out check -----------------------------------
 	 * check for a transmit interrupt timeout
 	 * Has the packet xmt vs xmt serviced threshold been exceeded */
@@ -632,29 +611,16 @@ static void lmc_watchdog(unsigned long data)
 		   sc->lmc_device->stats.tx_packets > sc->lasttx_packets &&
 		   sc->tx_TimeoutInd) {
=20
-		LMC_EVENT_LOG(LMC_EVENT_XMTINTTMO,
-			      LMC_CSR_READ(sc, csr_status), 0);
-
 		sc->tx_TimeoutDisplay =3D 1;
 		sc->extra_stats.tx_TimeoutCnt++;
=20
 		/* DEC chip is stuck, hit it with a RESET!!!! */
 		lmc_running_reset(dev);
=20
-
 		/* look at receive & transmit process state to make sure
-		   they are running */
-		LMC_EVENT_LOG(LMC_EVENT_RESET1,
-			      LMC_CSR_READ(sc, csr_status), 0);
-
-		/* look at: DSR - 02  for Reg 16
-		 *          CTS - 08
-		 *          DCD - 10
-		 *          RI  - 20
-		 * for Reg 17
-		 */
-		LMC_EVENT_LOG(LMC_EVENT_RESET2, lmc_mii_readreg(sc, 0, 16),
-			      lmc_mii_readreg(sc, 0, 17));
+		   they are running
+		   Reg 16: DSR =3D 2
+		   Reg 17: CTS =3D 8, DCD =3D 10, RI =3D 20 */
=20
 		/* reset the transmit timeout detection flag */
 		sc->tx_TimeoutInd =3D 0;
@@ -934,10 +900,6 @@ static int lmc_open(struct net_device *dev)
 	lmc_dec_reset(sc);
 	lmc_reset(sc);
=20
-	LMC_EVENT_LOG(LMC_EVENT_RESET1, LMC_CSR_READ(sc, csr_status), 0);
-	LMC_EVENT_LOG(LMC_EVENT_RESET2, lmc_mii_readreg(sc, 0, 16),
-		      lmc_mii_readreg(sc, 0, 17));
-
 	if (sc->lmc_ok) {
 		lmc_trace(dev, "lmc_open lmc_ok out");
 		return 0;
@@ -1204,8 +1166,6 @@ static irqreturn_t lmc_interrupt(int irq, void *d=
ev_instance)
 			while ((badtx < sc->lmc_next_tx)) {
 				stat =3D sc->lmc_txring[i].status;
=20
-				LMC_EVENT_LOG(LMC_EVENT_XMTINT, stat,
-					      sc->lmc_txring[i].length);
 				/* If bit 31 is 1 the tulip owns it break out
 				   of the loop */
 				if (stat & 0x80000000)
@@ -1249,7 +1209,6 @@ static irqreturn_t lmc_interrupt(int irq, void *d=
ev_instance)
 				       dev->name);
 				badtx +=3D LMC_TXDESCS;
 			}
-			LMC_EVENT_LOG(LMC_EVENT_TBUSY0, n_compl, 0);
 			sc->lmc_txfull =3D 0;
 			netif_wake_queue(dev);
 			sc->extra_stats.tx_tbusy0++;
@@ -1289,12 +1248,6 @@ static irqreturn_t lmc_interrupt(int irq, void *=
dev_instance)
 			}
 			lmc_dec_reset(sc);
 			lmc_reset(sc);
-			LMC_EVENT_LOG(LMC_EVENT_RESET1,
-				      LMC_CSR_READ(sc, csr_status), 0);
-			LMC_EVENT_LOG(LMC_EVENT_RESET2,
-				      lmc_mii_readreg(sc, 0, 16),
-				      lmc_mii_readreg(sc, 0, 17));
-
 		}
=20
 		if (max_work-- <=3D 0)
@@ -1304,7 +1257,6 @@ static irqreturn_t lmc_interrupt(int irq, void *d=
ev_instance)
 		   interrupts */
 		csr =3D LMC_CSR_READ(sc, csr_status);
 	} /* end interrupt loop */
-	LMC_EVENT_LOG(LMC_EVENT_INT, firstcsr, csr);
=20
 lmc_int_fail_out:
 	spin_unlock(&sc->lmc_lock);
@@ -1364,7 +1316,6 @@ static netdev_tx_t lmc_start_xmit(struct sk_buff =
*skb,
 		sc->lmc_txfull =3D 1;
 		netif_stop_queue(dev);
 		sc->extra_stats.tx_tbusy1++;
-		LMC_EVENT_LOG(LMC_EVENT_TBUSY1, entry, 0);
 	}
 #endif
=20
@@ -1382,7 +1333,6 @@ static netdev_tx_t lmc_start_xmit(struct sk_buff =
*skb,
 	sc->lmc_next_tx++;
=20
 	/* give ownership to the chip */
-	LMC_EVENT_LOG(LMC_EVENT_XMT, flag, entry);
 	sc->lmc_txring[entry].status =3D 0x80000000;
=20
 	/* send now! */
@@ -1522,7 +1472,6 @@ give_it_anyways:
 				   and stop in which care we'll try to allocate
 				   the buffer again (once a second). */
 				sc->extra_stats.rx_BuffAllocErr++;
-				LMC_EVENT_LOG(LMC_EVENT_RCVINT, stat, len);
 				sc->failed_recv_alloc =3D 1;
 				goto skip_out_of_mem;
 			}
@@ -1543,7 +1492,6 @@ give_it_anyways:
 		}
=20
 skip_packet:
-		LMC_EVENT_LOG(LMC_EVENT_RCVINT, stat, len);
 		sc->lmc_rxring[i].status =3D DESC_OWNED_BY_DC21X4;
=20
 		sc->lmc_next_rx++;
@@ -1557,11 +1505,8 @@ skip_packet:
 	/* detect condition for LMC1000 where DSU cable attaches and fills
 	   descriptors with bogus packets */
=20
-	if (localLengthErrCnt > LMC_RXDESCS - 3) {
+	if (localLengthErrCnt > LMC_RXDESCS - 3)
 		sc->extra_stats.rx_BadPktSurgeCnt++;
-		LMC_EVENT_LOG(LMC_EVENT_BADPKTSURGE, localLengthErrCnt,
-			      sc->extra_stats.rx_BadPktSurgeCnt);
-	}
 #endif
=20
 	/* save max count of receive descriptors serviced */
@@ -1575,7 +1520,6 @@ skip_packet:
 			    !=3D DESC_OWNED_BY_DC21X4)
 				rxIntLoopCnt++;
 		}
-		LMC_EVENT_LOG(LMC_EVENT_RCVEND, rxIntLoopCnt, 0);
 	}
 #endif
=20
@@ -1950,15 +1894,8 @@ static void lmc_driver_timeout(struct net_device=
 *dev)
 	/* Chip seems to have locked up. Reset it. This whips out all our
 	   decriptor table and starts from scartch. */
=20
-	LMC_EVENT_LOG(LMC_EVENT_XMTPRCTMO, LMC_CSR_READ(sc, csr_status),
-		      sc->extra_stats.tx_ProcTimeout);
-
 	lmc_running_reset(dev);
=20
-	LMC_EVENT_LOG(LMC_EVENT_RESET1, LMC_CSR_READ(sc, csr_status), 0);
-	LMC_EVENT_LOG(LMC_EVENT_RESET2, lmc_mii_readreg(sc, 0, 16),
-		      lmc_mii_readreg(sc, 0, 17));
-
 	/* restart the tx processes */
 	csr6 =3D LMC_CSR_READ(sc, csr_command);
 	LMC_CSR_WRITE(sc, csr_command, csr6 | 0x0002);
--=20
1.7.1.1

