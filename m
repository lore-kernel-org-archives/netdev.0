From: Parag Warudkar <parag.warudkar@gmail.com>
Subject: [PATCH] e1000e: Use deferrable timer for watchdog
Date: Tue, 18 Dec 2007 20:49:47 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0712182046560.3616@mini.warudkars.net>
Reply-To: parag.warudkar@gmail.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: netdev@vger.kernel.org, linux.nics@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:57325 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbXLSBt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 20:49:58 -0500
Received: by py-out-1112.google.com with SMTP id u77so4453959pyb.16
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 17:49:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Reduce wakeups from idle per second.

Signed-off-by: Parag Warudkar <parag.warudkar@gmail.com>

--- linux-2.6/drivers/net/e1000e/netdev.c	2007-12-07 10:04:39.000000000 -0500
+++ linux-2.6-work/drivers/net/e1000e/netdev.c	2007-12-18 20:45:59.000000000 -0500
@@ -3899,7 +3899,7 @@
  		goto err_eeprom;
  	}

-	init_timer(&adapter->watchdog_timer);
+	init_timer_deferrable(&adapter->watchdog_timer);
  	adapter->watchdog_timer.function = &e1000_watchdog;
  	adapter->watchdog_timer.data = (unsigned long) adapter;

