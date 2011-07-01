From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next v2] net: de4x5: Omit check for multicast bit in netdev_for_each_mc_addr
Date: Fri,  1 Jul 2011 09:37:52 +0200
Message-ID: <1309505872-28090-1-git-send-email-tklauser@distanz.ch>
References: <1309349760-1776-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:34268 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755275Ab1GAHhy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2011 03:37:54 -0400
In-Reply-To: <1309349760-1776-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to check for the address being a multicast address in
the netdev_for_each_mc_addr loop, so remove it.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/tulip/de4x5.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index efaa1d6..d8db2b6 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -1964,9 +1964,7 @@ SetMulticastFilter(struct net_device *dev)
 	omr |= OMR_PM;                       /* Pass all multicasts */
     } else if (lp->setup_f == HASH_PERF) {   /* Hash Filtering */
 	netdev_for_each_mc_addr(ha, dev) {
-	    addrs = ha->addr;
-	    if ((*addrs & 0x01) == 1) {      /* multicast address? */
-		crc = ether_crc_le(ETH_ALEN, addrs);
+		crc = ether_crc_le(ETH_ALEN, ha->addr);
 		hashcode = crc & HASH_BITS;  /* hashcode is 9 LSb of CRC */
 
 		byte = hashcode >> 3;        /* bit[3-8] -> byte in filter */
@@ -1977,7 +1975,6 @@ SetMulticastFilter(struct net_device *dev)
 		    byte -= 1;
 		}
 		lp->setup_frame[byte] |= bit;
-	    }
 	}
     } else {                                 /* Perfect filtering */
 	netdev_for_each_mc_addr(ha, dev) {
-- 
1.7.5.4

