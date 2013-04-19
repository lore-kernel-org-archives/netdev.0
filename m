From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2] net: ax88796: avoid 64 bit arithmetic
Date: Fri, 19 Apr 2013 20:47:26 +0200
Message-ID: <201304192047.26720.arnd@arndb.de>
References: <201304191506.21220.arnd@arndb.de> <20130419.133603.1487086024178553164.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@fluff.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:58322 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108Ab3DSSrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 14:47:40 -0400
In-Reply-To: <20130419.133603.1487086024178553164.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When building ax88796 on an ARM platform with 64-bit resource_size_t,
we currently get

drivers/net/ethernet/8390/ax88796.c:875: undefined reference to `__aeabi_uldivmod'

because we do a division on the length of the MMIO resource.
Since we know that this resource is very short, using an
"unsigned long" instead of "resource_size_t" is entirely
sufficient, and avoids this link-time error.

Cc: Ben Dooks <ben-linux@fluff.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index cab306a..e1d2643 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -828,7 +828,7 @@ static int ax_probe(struct platform_device *pdev)
 	struct ei_device *ei_local;
 	struct ax_device *ax;
 	struct resource *irq, *mem, *mem2;
-	resource_size_t mem_size, mem2_size = 0;
+	unsigned long mem_size, mem2_size = 0;
 	int ret = 0;
 
 	dev = ax__alloc_ei_netdev(sizeof(struct ax_device));
