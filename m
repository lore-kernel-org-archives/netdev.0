From: Parag Warudkar <parag.warudkar@gmail.com>
Subject: [PATCH] sky2: Use deferrable timer for watchdog
Date: Tue, 18 Dec 2007 20:13:28 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0712182008160.3616@mini.warudkars.net>
Reply-To: parag.warudkar@gmail.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: shemminger@linux-foundation.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:7355 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752765AbXLSBNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 20:13:32 -0500
Received: by py-out-1112.google.com with SMTP id u77so4429614pyb.16
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 17:13:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


sky2 can use deferrable timer for watchdog - reduces wakeups from idle per 
second.

Signed-off-by: Parag Warudkar <parag.warudkar@gmail.com>

--- linux-2.6/drivers/net/sky2.c	2007-12-07 10:04:39.000000000 -0500
+++ linux-2.6-work/drivers/net/sky2.c	2007-12-18 20:07:58.000000000 -0500
@@ -4230,7 +4230,10 @@
  			sky2_show_addr(dev1);
  	}

-	setup_timer(&hw->watchdog_timer, sky2_watchdog, (unsigned long) hw);
+	hw->watchdog_timer.function = sky2_watchdog;
+	hw->watchdog_timer.data = (unsigned long) hw;
+	init_timer_deferrable(&hw->watchdog_timer);
+
  	INIT_WORK(&hw->restart_work, sky2_restart);

  	pci_set_drvdata(pdev, hw);
