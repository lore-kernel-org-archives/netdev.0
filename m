From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] macvlan: propagate the mac address change status for lowerdev
Date: Tue, 13 Jun 2017 22:45:11 +0800
Message-ID: <1497365111-34821-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, fgao@ikuai8.com, vyasevic@redhat.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:47632 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752326AbdFMOpW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 10:45:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macvlan dev should propagate the return value of mac address change for
lower device in the passthru mode, instead of always return 0.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/macvlan.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 346ad2f..ade1213 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -703,10 +703,8 @@ static int macvlan_set_mac_address(struct net_device *dev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	if (vlan->mode == MACVLAN_MODE_PASSTHRU) {
-		dev_set_mac_address(vlan->lowerdev, addr);
-		return 0;
-	}
+	if (vlan->mode == MACVLAN_MODE_PASSTHRU)
+		return dev_set_mac_address(vlan->lowerdev, addr);
 
 	return macvlan_sync_address(dev, addr->sa_data);
 }
-- 
1.8.3.1
