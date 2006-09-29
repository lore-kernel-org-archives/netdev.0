From: Bill Helfinstine <bhelf@flitterfly.whirpon.com>
Subject: [PATCH] b44: fix multicast with >32 groups
Date: Fri, 29 Sep 2006 17:53:25 -0400
Message-ID: <451D95D5.5010005@flitterfly.whirpon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bhelf@flitterfly.whirpon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yam.whirpon.com ([72.9.242.239]:62354 "EHLO yam.whirpon.com")
	by vger.kernel.org with ESMTP id S932396AbWI2Vxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 17:53:40 -0400
To: zambrano@broadcom.com, netdev@vger.kernel.org, jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The b44 driver has a bug where if there are more than B44_MCAST_TABLE_SIZE 
groups in the dev->mc_list, it will only listen to the first 
B44_MCAST_TABLE_SIZE that it sees.

This patch makes the driver go into RXCONFIG_ALLMULTI mode if there are more 
than B44_MCAST_TABLE_SIZE groups being subscribed to.

This patch is against 2.6.18, b44.c version 1.01.


Signed-off-by: Bill Helfinstine <bhelf@flitterfly.whirpon.com>

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index e891ea2..dd024e1 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1706,7 +1706,8 @@ static void __b44_set_rx_mode(struct net

                 __b44_set_mac_addr(bp);

-               if (dev->flags & IFF_ALLMULTI)
+               if ((dev->flags & IFF_ALLMULTI) ||
+                   (dev->mc_count > B44_MCAST_TABLE_SIZE))
                         val |= RXCONFIG_ALLMULTI;
                 else
                         i = __b44_load_mcast(bp, dev);
