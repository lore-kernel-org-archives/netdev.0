From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH,pktgen] account for preamble and inter-packet gap
Date: Sun, 28 Nov 2004 22:32:51 +0100
Message-ID: <20041128213251.GA9330@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: robert.olsson@data.slu.se
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

If you account for the Frame Check Sequence when computing bandwidth
stats, it's only fair that you count the preamble and inter-packet gap
as well.  Suggested patch attached.


cheers,
Lennert


--- pktgen.c.orig	2004-11-28 22:27:50.008829106 +0100
+++ pktgen.c	2004-11-28 22:30:48.773867119 +0100
@@ -2564,7 +2564,7 @@
 static void show_results(struct pktgen_dev *pkt_dev, int nr_frags)
 {
        __u64 total_us, bps, mbps, pps, idle;
-       int size = pkt_dev->cur_pkt_size + 4; /* incl 32bit ethernet CRC */
+       int size = pkt_dev->cur_pkt_size + 4 + 8 + 12; /* incl 32bit ethernet CRC plus preamble plus inter-packet gap */
        char *p = pkt_dev->result;
 
        total_us = pkt_dev->stopped_at - pkt_dev->started_at;
@@ -2777,7 +2777,7 @@
 			pkt_dev->last_ok = 1;    
 			pkt_dev->sofar++;
 			pkt_dev->seq_num++;
-			pkt_dev->tx_bytes += (pkt_dev->cur_pkt_size + 4); /* count csum */
+			pkt_dev->tx_bytes += (pkt_dev->cur_pkt_size + 4 + 8 + 12); /* count csum and preamble and inter-packet gap*/
 			
 		} else if (ret == NETDEV_TX_LOCKED 
 			   && (odev->features & NETIF_F_LLTX)) {
