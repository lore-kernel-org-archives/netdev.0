From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] pktgen: nmi watchdog keep alive
Date: Sat, 19 Sep 2009 22:21:03 -0700
Message-ID: <20090919222103.017b5d5f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Robert Olsson <robert@herjulf.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33572 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269AbZITFVF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Sep 2009 01:21:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If pktgen gets really busy it takes up all the CPU,
and can starve the NMI thread and cause system reset.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/pktgen.c	2009-09-19 11:28:53.762463050 -0700
+++ b/net/core/pktgen.c	2009-09-19 11:30:36.534459968 -0700
@@ -136,6 +136,7 @@
 #include <linux/delay.h>
 #include <linux/timer.h>
 #include <linux/list.h>
+#include <linux/nmi.h>
 #include <linux/init.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
@@ -3369,6 +3370,7 @@ static void idle(struct pktgen_dev *pkt_
 {
 	ktime_t idle_start = ktime_now();
 
+	touch_nmi_watchdog();
 	if (need_resched())
 		schedule();
 	else
