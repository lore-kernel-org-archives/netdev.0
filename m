From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 5/5 2.5] e100: More DPRINTK messages to log driver state
Date: Fri, 15 Oct 2004 06:53:57 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150558250.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up netdev-2.6/drivers/net/e100.c netdev-2.6/drivers/net/e100.c.new
--- netdev-2.6/drivers/net/e100.c	2004-10-07 13:58:59.000000000 -0700
+++ netdev-2.6/drivers/net/e100.c.new	2004-10-07 13:59:00.000000000 -0700
@@ -1308,6 +1308,7 @@ static int e100_xmit_frame(struct sk_buf
 	switch(err) {
 	case -ENOSPC:
 		/* We queued the skb, but now we're out of space. */
+		DPRINTK(TX_ERR, DEBUG, "No space for CB\n");
 		netif_stop_queue(netdev);
 		break;
 	case -ENOMEM:
@@ -1966,6 +1954,8 @@ static int e100_set_ringparam(struct net
 	rfds->count = min(rfds->count, rfds->max);
 	cbs->count = max(ring->tx_pending, cbs->min);
 	cbs->count = min(cbs->count, cbs->max);
+	DPRINTK(DRV, INFO, "Ring Param settings: rx: %d, tx %d\n", 
+	        rfds->count, cbs->count);
 	if(netif_running(netdev))
 		e100_up(nic);
 
