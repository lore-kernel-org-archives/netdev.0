From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 2/2] macvlan: propagate lowerdev mac address changes for passthru mode
Date: Mon, 26 May 2014 20:10:33 +0800
Message-ID: <1401106233-11320-3-git-send-email-dingtianhong@huawei.com>
References: <1401106233-11320-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:32861 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656AbaEZMLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 08:11:13 -0400
In-Reply-To: <1401106233-11320-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macvlan dev should have the same mac address like lowerdev for passthru
mode, so when the lowerdev address changes we should change the macvlan dev
to the new mac address. This patch adds that propagation.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/macvlan.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 7bd9082..55faff3 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1116,6 +1116,18 @@ static int macvlan_device_event(struct notifier_block *unused,
 			dev_set_mtu(vlan->dev, dev->mtu);
 		}
 		break;
+	case NETDEV_CHANGEADDR:
+		if (!port->passthru)
+			return NOTIFY_DONE;
+
+		vlan = list_first_entry_or_null(&port->vlans,
+						struct macvlan_dev,
+						list);
+
+		if (macvlan_sync_address(vlan->dev, dev->dev_addr))
+			return NOTIFY_BAD;
+
+		break;
 	case NETDEV_UNREGISTER:
 		/* twiddle thumbs on netns device moves */
 		if (dev->reg_state != NETREG_UNREGISTERING)
-- 
1.8.0
