From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 01/17] sky2: fix oops on shutdown
Date: Tue, 08 May 2007 20:49:50 -0700
Message-ID: <20070509035027.805096061@linux-foundation.org>
References: <20070509034949.624934448@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:54770 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1032258AbXEIEDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:03:25 -0400
Cc: stable@vger.kernel.org
Content-Disposition: inline; filename=sky2-shutdown.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If device is not fails during module startup (like unsupported chip
version) then driver would crash dereferencing a null pointer.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    4 ++++
 1 file changed, 4 insertions(+)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-05-08 15:14:45.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-05-08 15:16:12.000000000 -0700
@@ -3732,6 +3732,7 @@ err_out_free_regions:
 err_out_disable:
 	pci_disable_device(pdev);
 err_out:
+	pci_set_drvdata(pdev, NULL);
 	return err;
 }
 
@@ -3861,6 +3862,9 @@ static void sky2_shutdown(struct pci_dev
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
 	int i, wol = 0;
 
+	if (!hw)
+		return;
+
 	del_timer_sync(&hw->idle_timer);
 	netif_poll_disable(hw->dev[0]);
 

--

