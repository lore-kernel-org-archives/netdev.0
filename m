From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [net-next 2/3] net: bcmgenet: fix warning on ndo_select_queue
Date: Thu, 20 Feb 2014 12:53:50 -0800
Message-ID: <1392929631-7685-3-git-send-email-f.fainelli@gmail.com>
References: <1392929631-7685-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:12461 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbaBTUyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 15:54:20 -0500
In-Reply-To: <1392929631-7685-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 99932d4 ("netdevice: add queue selection fallback handler for
ndo_select_queue") added a new argument to the ndo_select_queue callback,
but the BCMGENET driver was not updated accordingly and hence would
trigger a warning.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 8af5f07..7c023af 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2276,7 +2276,8 @@ static int bcmgenet_set_mac_addr(struct net_device *dev, void *p)
 }
 
 static u16 bcmgenet_select_queue(struct net_device *dev,
-		struct sk_buff *skb, void *accel_priv)
+		struct sk_buff *skb, void *accel_priv,
+		select_queue_fallback_t fallback)
 {
 	return netif_is_multiqueue(dev) ? skb->queue_mapping : 0;
 }
-- 
1.8.3.2
