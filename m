From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH] e1000e: Fix irq_synchronize in MSI-X case
Date: Tue, 20 Jul 2010 17:12:05 +0200
Message-ID: <201007201712.05671.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:33294 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760915Ab0GTPMI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jul 2010 11:12:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Synchronize all IRQs when in MSI-X IRQ mode.

Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: Bruce Allan <bruce.w.allan@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
---
I sent this patch to the e1000-devel list on June 8th, 2010, but
didn't receive any answer:
http://sourceforge.net/mailarchive/forum.php?thread_name=201006081818.59098.jdelvare%40suse.de&forum_name=e1000-devel

I don't know how critical synchronize_irq() is, so I don't know if
this patch should go to stable branches or not.

 drivers/net/e1000e/netdev.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1939,7 +1939,13 @@ static void e1000_irq_disable(struct e10
 	if (adapter->msix_entries)
 		ew32(EIAC_82574, 0);
 	e1e_flush();
-	synchronize_irq(adapter->pdev->irq);
+
+	if (adapter->msix_entries) {
+		synchronize_irq(adapter->msix_entries[0].vector);
+		synchronize_irq(adapter->msix_entries[1].vector);
+		synchronize_irq(adapter->msix_entries[2].vector);
+	} else
+		synchronize_irq(adapter->pdev->irq);
 }
 
 /**

-- 
Jean Delvare
Suse L3
