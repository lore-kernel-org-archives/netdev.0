From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] au1000_eth: possible NULL dereference of aup->mii_bus->irq
 in au1000_probe()
Date: Mon, 31 Aug 2009 10:40:15 +0200
Message-ID: <4A9B8C6F.3040503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:56819 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbZHaIei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 04:34:38 -0400
Received: by ewy2 with SMTP id 2so85745ewy.17
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2009 01:34:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

aup->mii_bus->irq allocation may fail, prevent a dereference of NULL.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index d3c734f..02e4be0 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -1157,6 +1157,9 @@ static struct net_device * au1000_probe(int port_num)
 	aup->mii_bus->name = "au1000_eth_mii";
 	snprintf(aup->mii_bus->id, MII_BUS_ID_SIZE, "%x", aup->mac_id);
 	aup->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
+	if (aup->mii_bus->irq == NULL)
+		goto err_out;
+
 	for(i = 0; i < PHY_MAX_ADDR; ++i)
 		aup->mii_bus->irq[i] = PHY_POLL;
 
