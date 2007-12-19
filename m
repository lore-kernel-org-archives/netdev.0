From: Parag Warudkar <parag.warudkar@gmail.com>
Subject: [PATCH] sch_generic.c: Make dev_watchdog use deferrable timer
Date: Tue, 18 Dec 2007 20:04:23 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0712181956180.3616@mini.warudkars.net>
Reply-To: parag.warudkar@gmail.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.236]:10822 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752616AbXLSBE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 20:04:29 -0500
Received: by wr-out-0506.google.com with SMTP id c49so1944106wra.1
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 17:04:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Reduces the number of wakeups from idle per second, makes powertop happy.

Signed-off-by: Parag Warudkar <parag.warudkar@gmail.com>

--- linux-2.6/net/sched/sch_generic.c	2007-12-07 10:04:43.000000000 -0500
+++ linux-2.6-work/net/sched/sch_generic.c	2007-12-16 17:57:05.000000000 -0500
@@ -213,7 +213,7 @@

  static void dev_watchdog_init(struct net_device *dev)
  {
-	init_timer(&dev->watchdog_timer);
+	init_timer_deferrable(&dev->watchdog_timer);
  	dev->watchdog_timer.data = (unsigned long)dev;
  	dev->watchdog_timer.function = dev_watchdog;
  }
