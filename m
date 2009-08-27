From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 07/14] pktgen: use netdev_alloc_skb
Date: Thu, 27 Aug 2009 16:55:13 -0700
Message-ID: <20090827235705.654336796@vyatta.com>
References: <20090827235506.624381734@vyatta.com>
Cc: netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58753 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752846AbZH0X7V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 19:59:21 -0400
Content-Disposition: inline; filename=pktgen-netdev-alloc.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev_alloc_skb is NUMA node aware.
Also, don't exhaust atomic emergency pool. Don't want pktgen
to cause OOM behaviour.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/core/pktgen.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

--- a/net/core/pktgen.c	2009-08-27 11:45:39.080959255 -0700
+++ b/net/core/pktgen.c	2009-08-27 11:57:08.683814034 -0700
@@ -2539,8 +2539,9 @@ static struct sk_buff *fill_packet_ipv4(
 	mod_cur_headers(pkt_dev);
 
 	datalen = (odev->hard_header_len + 16) & ~0xf;
-	skb = alloc_skb(pkt_dev->cur_pkt_size + 64 + datalen +
-			pkt_dev->pkt_overhead, GFP_ATOMIC);
+	skb = __netdev_alloc_skb(odev,
+				 pkt_dev->cur_pkt_size + 64
+				 + datalen + pkt_dev->pkt_overhead, GFP_NOWAIT);
 	if (!skb) {
 		sprintf(pkt_dev->result, "No memory");
 		return NULL;
@@ -2878,8 +2879,9 @@ static struct sk_buff *fill_packet_ipv6(
 	queue_map = pkt_dev->cur_queue_map;
 	mod_cur_headers(pkt_dev);
 
-	skb = alloc_skb(pkt_dev->cur_pkt_size + 64 + 16 +
-			pkt_dev->pkt_overhead, GFP_ATOMIC);
+	skb = __netdev_alloc_skb(odev,
+				 pkt_dev->cur_pkt_size + 64
+				 + 16 + pkt_dev->pkt_overhead, GFP_NOWAIT);
 	if (!skb) {
 		sprintf(pkt_dev->result, "No memory");
 		return NULL;

-- 

