From: Parag Warudkar <parag.warudkar@gmail.com>
Subject: [PATCH] e1000: Use deferrable timer for watchdog
Date: Tue, 18 Dec 2007 20:46:48 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0712182040470.3616@mini.warudkars.net>
Reply-To: parag.warudkar@gmail.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: linux.nics@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:21720 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753146AbXLSBqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 20:46:54 -0500
Received: by an-out-0708.google.com with SMTP id d31so691786and.103
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 17:46:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use deferrable timer for watchdog. Reduces wakeups from idle per second.

Signed-off-by: Parag Warudkar <parag.warudkar@gmail.com>

--- linux-2.6/drivers/net/e1000/e1000_main.c	2007-12-07 10:04:39.000000000 -0500
+++ linux-2.6-work/drivers/net/e1000/e1000_main.c	2007-12-18 20:38:38.000000000 -0500
@@ -1030,7 +1030,7 @@
  	adapter->tx_fifo_stall_timer.function = &e1000_82547_tx_fifo_stall;
  	adapter->tx_fifo_stall_timer.data = (unsigned long) adapter;

-	init_timer(&adapter->watchdog_timer);
+	init_timer_deferrable(&adapter->watchdog_timer);
  	adapter->watchdog_timer.function = &e1000_watchdog;
  	adapter->watchdog_timer.data = (unsigned long) adapter;

