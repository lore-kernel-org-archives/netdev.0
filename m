From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH] bridge: set priority of STP packets
Date: Mon, 11 Feb 2013 10:22:22 -0800
Message-ID: <20130211102222.37743b22@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:38129 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758777Ab3BKSWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 13:22:37 -0500
Received: by mail-pa0-f48.google.com with SMTP id hz10so3188425pad.21
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2013 10:22:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Spanning Tree Protocol packets should have always been marked as
control packets, this causes them to get queued in the high prirority
FIFO. As Radia Perlman mentioned in her LCA talk, STP dies if bridge
gets overloaded and can't communicate. This is a long-standing bug back
to the first versions of Linux bridge.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
Please consider adding to  stable as well.

--- a/net/bridge/br_stp_bpdu.c	2013-01-16 09:47:00.599539375 -0800
+++ b/net/bridge/br_stp_bpdu.c	2013-02-11 08:13:56.315979316 -0800
@@ -16,6 +16,7 @@
 #include <linux/etherdevice.h>
 #include <linux/llc.h>
 #include <linux/slab.h>
+#include <linux/pkt_sched.h>
 #include <net/net_namespace.h>
 #include <net/llc.h>
 #include <net/llc_pdu.h>
@@ -40,6 +41,7 @@ static void br_send_bpdu(struct net_brid
 
 	skb->dev = p->dev;
 	skb->protocol = htons(ETH_P_802_2);
+	skb->priority = TC_PRIO_CONTROL;
 
 	skb_reserve(skb, LLC_RESERVE);
 	memcpy(__skb_put(skb, length), data, length);
