From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] drivers/net/rionet.c: remove some pointless conditionals
 before kfree_skb()
Date: Wed, 25 Feb 2009 18:18:12 +0800
Message-ID: <49A51AE4.2070705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56585 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1759682AbZBYKSo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 05:18:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 drivers/net/rionet.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index a6fd27a..ec59e29 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -362,8 +362,7 @@ static int rionet_close(struct net_device *ndev)
 	netif_carrier_off(ndev);
 
 	for (i = 0; i < RIONET_RX_RING_SIZE; i++)
-		if (rnet->rx_skb[i])
-			kfree_skb(rnet->rx_skb[i]);
+		kfree_skb(rnet->rx_skb[i]);
 
 	list_for_each_entry_safe(peer, tmp, &rionet_peers, node) {
 		if (rionet_active[peer->rdev->destid]) {
-- 
1.5.3.8




