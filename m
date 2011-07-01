From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH net-next] net: de4x5: Omit check for multicast bit in
	netdev_for_each_mc_addr
Date: Fri, 1 Jul 2011 09:25:33 +0200
Message-ID: <20110701072533.GY28247@distanz.ch>
References: <1309349760-1776-1-git-send-email-tklauser@distanz.ch> <20110630.235730.726339338074212677.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: grundler@parisc-linux.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from symlink.to.noone.org ([85.10.207.172]:53064 "EHLO sym.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755254Ab1GAHfS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2011 03:35:18 -0400
Content-Disposition: inline
In-Reply-To: <20110630.235730.726339338074212677.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-07-01 at 08:57:30 +0200, David Miller <davem@davemloft.net> wrote:
> From: Tobias Klauser <tklauser@distanz.ch>
> Date: Wed, 29 Jun 2011 14:16:00 +0200
> 
> > There is no need to check for the address being a multicast address in
> > the netdev_for_each_mc_addr loop, so remove it.
> > 
> > Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> 
> Please build test your patches!

Sorry for the mess. Here's an updated patch, not removing the addrs
local variable.

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

