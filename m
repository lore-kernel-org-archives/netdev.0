From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next] macvlan: Propagate lowerdev MTU changes
Date: Tue, 13 May 2014 14:39:27 +0800
Message-ID: <5371BE1F.7030508@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:20546 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756403AbaEMGkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 02:40:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the physical MTU changes we should ensure that all existing MACVLAN
dev MTU do not exceed the new lowerdev MTU. This patch adds that
propagation.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/macvlan.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index f0118d1..e03707d 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1091,6 +1091,13 @@ static int macvlan_device_event(struct notifier_block *unused,
 			netdev_update_features(vlan->dev);
 		}
 		break;
+	case NETDEV_CHANGEMTU:
+		list_for_each_entry(vlan, &port->vlans, list) {
+			if (vlan->dev->mtu <= dev->mtu)
+				continue;
+			dev_set_mtu(vlan->dev, dev->mtu);
+		}
+		break;
 	case NETDEV_UNREGISTER:
 		/* twiddle thumbs on netns device moves */
 		if (dev->reg_state != NETREG_UNREGISTERING)
-- 
1.8.0
