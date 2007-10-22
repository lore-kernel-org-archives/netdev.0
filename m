From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: crash on remove
Date: Mon, 22 Oct 2007 13:39:09 -0700
Message-ID: <20071022133909.6a5453c7@freepuppy.rosehill>
References: <bug-9208-10286@http.bugzilla.kernel.org/>
	<20071022111235.266a10df.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jkarlson@cc.hut.fi
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35396 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751989AbXJVUkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 16:40:39 -0400
In-Reply-To: <20071022111235.266a10df.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix off-by one in remove logic that just got introduced.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
This only occurs in new post 2.6.23 code.

--- a/drivers/net/sky2.c	2007-10-22 09:38:11.000000000 -0700
+++ b/drivers/net/sky2.c	2007-10-22 12:11:22.000000000 -0700
@@ -4271,7 +4271,7 @@ static void __devexit sky2_remove(struct
 	del_timer_sync(&hw->watchdog_timer);
 	cancel_work_sync(&hw->restart_work);
 
-	for (i = hw->ports; i >= 0; --i)
+	for (i = hw->ports-1; i >= 0; --i)
 		unregister_netdev(hw->dev[i]);
 
 	sky2_write32(hw, B0_IMSK, 0);
@@ -4289,7 +4289,7 @@ static void __devexit sky2_remove(struct
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 
-	for (i = hw->ports; i >= 0; --i)
+	for (i = hw->ports-1; i >= 0; --i)
 		free_netdev(hw->dev[i]);
 
 	iounmap(hw->regs);
