From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] drivers/net/au1000_eth.c: Remove misuse of
 DECLARE_MAC_BUF
Date: Sun, 06 Dec 2009 12:32:43 -0800
Message-ID: <1260131563.11126.124.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1077 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757457AbZLFUch (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2009 15:32:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And use a directly declared buffer.

It's used in a call to prom_get_ethernet_addr to
get a 6 byte address, not a formatted output string.

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 1acf2c1..af271fa 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -1006,7 +1006,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	db_dest_t *pDB, *pDBfree;
 	int irq, i, err = 0;
 	struct resource *base, *macen;
-	DECLARE_MAC_BUF(ethaddr);
+	char ethaddr[ETH_ALEN];
 
 	base = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!base) {


