From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/defxx.c: use %pMF to show MAC address
Date: Thu, 7 Jan 2010 16:24:19 -0700
Message-ID: <201001071624.20139.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: macro@linux-mips.org, davem@davemloft.net
To: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [206.15.93.42] ([206.15.93.42]:12352 "EHLO
	visionfs1.visionengravers.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752541Ab0AGXYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 18:24:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the %pMF kernel extension to display the MAC address.

The address will still be displayed in the FDDI Canonical format.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Maciej W. Rozycki <macro@linux-mips.org>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
index 6a6ea03..e4eac4b 100644
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -1052,12 +1052,9 @@ static int __devinit dfx_driver_init(struct net_device *dev,
 		board_name = "DEFEA";
 	if (dfx_bus_pci)
 		board_name = "DEFPA";
-	pr_info("%s: %s at %saddr = 0x%llx, IRQ = %d, "
-		"Hardware addr = %02X-%02X-%02X-%02X-%02X-%02X\n",
+	pr_info("%s: %s at %saddr = 0x%llx, IRQ = %d, Hardware addr = %pMF\n",
 		print_name, board_name, dfx_use_mmio ? "" : "I/O ",
-		(long long)bar_start, dev->irq,
-		dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-		dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+		(long long)bar_start, dev->irq, dev->dev_addr);
 
 	/*
 	 * Get memory for descriptor block, consumer block, and other buffers
