From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] 3c59x: shorten timer period for slave devices
Date: Tue, 14 Feb 2012 21:27:09 +0100
Message-ID: <1329251229.2555.10.camel@edumazet-laptop>
References: <1329218017.2336.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <201202141350.57657.jdelvare@suse.de> <20120214133418.GJ32155@v3-1054>
	 <20120214.144335.558771219791311889.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: klassert@mathematik.tu-chemnitz.de, jdelvare@suse.de,
	fubar@us.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:40354 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757241Ab2BNU1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 15:27:14 -0500
Received: by wics10 with SMTP id s10so89625wic.19
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 12:27:12 -0800 (PST)
In-Reply-To: <20120214.144335.558771219791311889.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jean Delvare reported bonding on top of 3c59x adapters was not detecting
network cable removal fast enough.

3c59x indeed uses a 60 seconds timer to check link status if carrier is
on, and 5 seconds if carrier is off.

This patch reduces timer period to 5 seconds if device is a bonding
slave.

Reported-by: Jean Delvare <jdelvare@suse.de>
Acked-by: Jean Delvare <jdelvare@suse.de>
Acked-by: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ethernet/3com/3c59x.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 1282f04..e463d10 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -1841,7 +1841,7 @@ vortex_timer(unsigned long data)
 		ok = 1;
 	}
 
-	if (!netif_carrier_ok(dev))
+	if (dev->flags & IFF_SLAVE || !netif_carrier_ok(dev))
 		next_tick = 5*HZ;
 
 	if (vp->medialock)
