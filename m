From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 2/2] ehea: Use round_jiffies_relative to align workqueue
Date: Wed, 23 Nov 2011 21:13:54 +1100
Message-ID: <20111123211354.74a81a88@kryten>
References: <20111123211302.2a37debb@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:58474 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751533Ab1KWKN4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 05:13:56 -0500
In-Reply-To: <20111123211302.2a37debb@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use round_jiffies_relative to align the ehea workqueue and avoid
extra wakeups.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-build/drivers/net/ethernet/ibm/ehea/ehea_main.c
===================================================================
--- linux-build.orig/drivers/net/ethernet/ibm/ehea/ehea_main.c	2011-11-23 16:04:23.941615040 +1100
+++ linux-build/drivers/net/ethernet/ibm/ehea/ehea_main.c	2011-11-23 16:04:55.654208250 +1100
@@ -371,7 +371,8 @@ static void ehea_update_stats(struct wor
 out_herr:
 	free_page((unsigned long)cb2);
 resched:
-	schedule_delayed_work(&port->stats_work, msecs_to_jiffies(1000));
+	schedule_delayed_work(&port->stats_work,
+			      round_jiffies_relative(msecs_to_jiffies(1000)));
 }
 
 static void ehea_refill_rq1(struct ehea_port_res *pr, int index, int nr_of_wqes)
@@ -2434,7 +2435,8 @@ static int ehea_open(struct net_device *
 	}
 
 	mutex_unlock(&port->port_lock);
-	schedule_delayed_work(&port->stats_work, msecs_to_jiffies(1000));
+	schedule_delayed_work(&port->stats_work,
+			      round_jiffies_relative(msecs_to_jiffies(1000)));
 
 	return ret;
 }
