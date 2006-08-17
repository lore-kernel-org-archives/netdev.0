From: Jesse Huang <jesse@icplus.com.tw>
Subject: [PATCH 6/7] ip1000: Add IPG_AC_FIFO flag when Tx reset
Date: Thu, 17 Aug 2006 15:49:02 -0400
Message-ID: <1155844142.5006.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr20.hinet.net ([168.95.4.120]:53713 "EHLO msr20.hinet.net")
	by vger.kernel.org with ESMTP id S932254AbWHQIBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 04:01:54 -0400
To: romieu@fr.zoreil.com, penberg@cs.Helsinki.FI, akpm@osdl.org,
	dvrabel@cantab.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, david@pleyades.net, jesse@icplus.com.tw
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Huang <jesse@icplus.com.tw>

This is a bug when Tx underrun happen, Tx reset without IPG_AC_FIFO will
cause Tx hold and can't transmit packet again.

Change Logs:
   1. Tx reset when Tx Under run will cause Tx fail
   2. ipg_nic_txcleanup() add "IPG_AC_FIFO" when Tx reset

---

 drivers/net/ipg.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

7e88cf9432ea466a76f7b26d11a280300c8735f2
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 56ffc80..ae22fa8 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -1036,7 +1036,7 @@ static void ipg_nic_txcleanup(struct net
 				IPG_DEBUG_MSG("Transmitter underrun.\n");
 				sp->stats.tx_fifo_errors++;
 				ipg_reset(dev, IPG_AC_TX_RESET |
-					  IPG_AC_DMA | IPG_AC_NETWORK);
+					  IPG_AC_DMA | IPG_AC_NETWORK| IPG_AC_FIFO);
 
 				/* Re-configure after DMA reset. */
 				if ((ipg_io_config(dev) < 0) ||
-- 
1.3.GIT



