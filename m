From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: fix misreporting of transmit abort
Date: Fri, 21 Jun 2013 01:13:42 +0400
Message-ID: <201306210113.43087.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Due to obviously missing braces, EESR.TABT (transmit abort) interrupt may be
reported even if it hasn't happened, just when EESR.TWB (transmit descriptor
write-back) interrupt happens. Luckily (?), EESR.TWB is disabled by the driver
via the TRIMD register and all the interrupt masks, so that transmit abort is
never actually logged...

Put the braces where they should be and fix the incoherent comment, while at it. 

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against Dave Miller's 'net.git' repo. Maybe it should be merged to
the 'net-next.git' repo instead, it's up to Dave to decide. The same can be said
about whether this should be merged to -stable...

 drivers/net/ethernet/renesas/sh_eth.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -1550,11 +1550,12 @@ static void sh_eth_error(struct net_devi
 
 ignore_link:
 	if (intr_status & EESR_TWB) {
-		/* Write buck end. unused write back interrupt */
-		if (intr_status & EESR_TABT)	/* Transmit Abort int */
+		/* Unused write back interrupt */
+		if (intr_status & EESR_TABT) {	/* Transmit Abort int */
 			ndev->stats.tx_aborted_errors++;
 			if (netif_msg_tx_err(mdp))
 				dev_err(&ndev->dev, "Transmit Abort\n");
+		}
 	}
 
 	if (intr_status & EESR_RABT) {
