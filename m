From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ehea: restore multicast and rx_errors fields
Date: Tue, 06 Mar 2012 21:46:41 -0800
Message-ID: <1331099201.2474.59.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Anton Blanchard <anton@samba.org>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:54004 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751317Ab2CGFqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 00:46:48 -0500
Received: by obbuo6 with SMTP id uo6so6436916obb.19
        for <netdev@vger.kernel.org>; Tue, 06 Mar 2012 21:46:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 239c562c94d (ehea: Add 64bit statistics) added a regression,
since we no longer report multicast & rx_errors fields, taken from
port->stats structure. These fields are updated in ehea_update_stats()
every second.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Anton Blanchard <anton@samba.org>
Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 5d5fb26..e6893cd 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -336,7 +336,9 @@ static struct rtnl_link_stats64 *ehea_get_stats64(struct net_device *dev,
 	stats->tx_bytes = tx_bytes;
 	stats->rx_packets = rx_packets;
 
-	return &port->stats;
+	stats->multicast = port->stats.multicast;
+	stats->rx_errors = port->stats.rx_errors;
+	return stats;
 }
 
 static void ehea_update_stats(struct work_struct *work)
