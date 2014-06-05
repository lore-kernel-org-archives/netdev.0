From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 1/4] macvlan: don't update the uc and vlan list for L2 forwarding offload
Date: Thu, 5 Jun 2014 14:50:25 +0800
Message-ID: <1401951028-9800-2-git-send-email-dingtianhong@huawei.com>
References: <1401951028-9800-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>, <edumazet@google.com>,
	<vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:26004 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbaFEGv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 02:51:26 -0400
In-Reply-To: <1401951028-9800-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If lowerdev supports L2 forwarding offload, no need to set mac address
to uc list and vlan list, so also don't do that when the macvlan mac address
changes.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/macvlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 453d55a..c3a54a6 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -515,7 +515,7 @@ static int macvlan_sync_address(struct net_device *dev, unsigned char *addr)
 	struct net_device *lowerdev = vlan->lowerdev;
 	int err;
 
-	if (!(dev->flags & IFF_UP)) {
+	if (!(dev->flags & IFF_UP) || vlan->fwd_priv) {
 		/* Just copy in the new address */
 		ether_addr_copy(dev->dev_addr, addr);
 	} else {
-- 
1.8.0
