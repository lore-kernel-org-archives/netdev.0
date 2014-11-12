From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH net-next] sunvnet: fix NULL pointer dereference
Date: Wed, 12 Nov 2014 10:58:47 -0500
Message-ID: <546383B7.2090106@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33895 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858AbaKLP6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 10:58:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a NULL pointer dereference when __tx_port_find() doesn't
find a matching port.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 55d66c9..a556eba 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -958,6 +958,8 @@ vnet_select_queue(struct net_device *dev, struct sk_buff *skb,
 	struct vnet *vp = netdev_priv(dev);
 	struct vnet_port *port = __tx_port_find(vp, skb);
 
+	if (port == NULL)
+		return 0;
 	return port->q_index;
 }
 
-- 
1.7.1
