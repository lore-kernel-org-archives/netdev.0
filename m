From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH net-next] sunvnet: fix potential NULL pointer dereference
Date: Wed, 01 Oct 2014 11:05:27 -0400
Message-ID: <542C1837.6090009@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24331 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367AbaJAPFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 11:05:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One of the error cases for vnet_start_xmit()'s "out_dropped" label
is port == NULL, so only mess with port->clean_timer when port is not NULL.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 1262697..1539672 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -1073,7 +1073,7 @@ out_dropped:
 	if (pending)
 		(void)mod_timer(&port->clean_timer,
 				jiffies + VNET_CLEAN_TIMEOUT);
-	else
+	else if (port)
 		del_timer(&port->clean_timer);
 	dev->stats.tx_dropped++;
 	return NETDEV_TX_OK;
-- 
1.7.1
