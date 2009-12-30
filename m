From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/defxx.c: use %pM to show MAC address
Date: Wed, 30 Dec 2009 13:28:38 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F63E@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6ob111.obsmtp.com ([64.18.1.26]:46288 "HELO psmtp.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751575AbZL3S2k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2009 13:28:40 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the %pM kernel extension to display the MAC address.

The only difference in the output is that the MAC address is
shown in the usual colon-separated hex notation.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
index 6a6ea03..d27b716 100644
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -1052,12 +1052,9 @@ static int __devinit dfx_driver_init(struct net_device *dev,
 		board_name = "DEFEA";
 	if (dfx_bus_pci)
 		board_name = "DEFPA";
-	pr_info("%s: %s at %saddr = 0x%llx, IRQ = %d, "
-		"Hardware addr = %02X-%02X-%02X-%02X-%02X-%02X\n",
+	pr_info("%s: %s at %saddr = 0x%llx, IRQ = %d, Hardware addr = %pM\n",
 		print_name, board_name, dfx_use_mmio ? "" : "I/O ",
-		(long long)bar_start, dev->irq,
-		dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-		dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+		(long long)bar_start, dev->irq, dev->dev_addr);
 
 	/*
 	 * Get memory for descriptor block, consumer block, and other buffers 
