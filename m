From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Mon, 21 May 2007 19:51:50 -0400
Message-ID: <20070521235150.GA29114@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:45513 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759110AbXEUXvv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 19:51:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Two fixes and a one-line constant addition.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/declance.c         |    2 --
 drivers/net/e1000/e1000_main.c |    4 ----
 include/linux/if_ether.h       |    1 +
 3 files changed, 1 insertions(+), 6 deletions(-)

Auke Kok (2):
      e1000: Don't enable polling in open() (was: e1000: assertion hit in e1000_clean(), kernel 2.6.21.1)
      Add constant for FCS/CRC length (frame check sequence)

Maciej W. Rozycki (1):
      declance: Remove a dangling spin_unlock_irq() thingy

diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index 95d854e..b2577f4 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -932,8 +932,6 @@ static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Kick the lance: transmit now */
 	writereg(&ll->rdp, LE_C0_INEA | LE_C0_TDMD);
 
-	spin_unlock_irq(&lp->lock);
-
 	dev->trans_start = jiffies;
 	dev_kfree_skb(skb);
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 49be393..cbc7feb 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1431,10 +1431,6 @@ e1000_open(struct net_device *netdev)
 	/* From here on the code is the same as e1000_up() */
 	clear_bit(__E1000_DOWN, &adapter->flags);
 
-#ifdef CONFIG_E1000_NAPI
-	netif_poll_enable(netdev);
-#endif
-
 	e1000_irq_enable(adapter);
 
 	/* fire a link status change interrupt to start the watchdog */
diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 1db774c..3213f6f 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -33,6 +33,7 @@
 #define ETH_ZLEN	60		/* Min. octets in frame sans FCS */
 #define ETH_DATA_LEN	1500		/* Max. octets in payload	 */
 #define ETH_FRAME_LEN	1514		/* Max. octets in frame sans FCS */
+#define ETH_FCS_LEN	4		/* Octets in the FCS		 */
 
 /*
  *	These are the defined Ethernet Protocol ID's.
