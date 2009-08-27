From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 04/14] pktgen: stop_device cleanup
Date: Thu, 27 Aug 2009 16:55:10 -0700
Message-ID: <20090827235705.416550256@vyatta.com>
References: <20090827235506.624381734@vyatta.com>
Cc: netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58758 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752770AbZH0X72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 19:59:28 -0400
Content-Disposition: inline; filename=pktgen-stop-dev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All the callers were freeing skb after stopping device.
Remove unneeded forward decl.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/core/pktgen.c |   12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

--- a/net/core/pktgen.c	2009-08-27 11:35:23.949541813 -0700
+++ b/net/core/pktgen.c	2009-08-27 11:57:11.370662155 -0700
@@ -424,7 +424,7 @@ static int pktgen_device_event(struct no
 static void pktgen_run_all_threads(void);
 static void pktgen_reset_all_threads(void);
 static void pktgen_stop_all_threads_ifs(void);
-static int pktgen_stop_device(struct pktgen_dev *pkt_dev);
+
 static void pktgen_stop(struct pktgen_thread *t);
 static void pktgen_clear_counters(struct pktgen_dev *pkt_dev);
 
@@ -3221,7 +3221,6 @@ static void show_results(struct pktgen_d
 }
 
 /* Set stopped-at timer, remove from running list, do counters & statistics */
-
 static int pktgen_stop_device(struct pktgen_dev *pkt_dev)
 {
 	int nr_frags = pkt_dev->skb ? skb_shinfo(pkt_dev->skb)->nr_frags : -1;
@@ -3232,6 +3231,8 @@ static int pktgen_stop_device(struct pkt
 		return -EINVAL;
 	}
 
+	kfree_skb(pkt_dev->skb);
+	pkt_dev->skb = NULL;
 	pkt_dev->stopped_at = getCurUs();
 	pkt_dev->running = 0;
 
@@ -3268,9 +3269,6 @@ static void pktgen_stop(struct pktgen_th
 
 	list_for_each_entry(pkt_dev, &t->if_list, list) {
 		pktgen_stop_device(pkt_dev);
-		kfree_skb(pkt_dev->skb);
-
-		pkt_dev->skb = NULL;
 	}
 
 	if_unlock(t);
@@ -3382,8 +3380,6 @@ static void pktgen_xmit(struct pktgen_de
 
 		if (!netif_running(odev)) {
 			pktgen_stop_device(pkt_dev);
-			kfree_skb(pkt_dev->skb);
-			pkt_dev->skb = NULL;
 			goto out;
 		}
 		if (need_resched())
@@ -3486,8 +3482,6 @@ static void pktgen_xmit(struct pktgen_de
 
 		/* Done with this */
 		pktgen_stop_device(pkt_dev);
-		kfree_skb(pkt_dev->skb);
-		pkt_dev->skb = NULL;
 	}
 out:;
 }

-- 

