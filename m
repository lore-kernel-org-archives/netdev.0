From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH cumulus-4.1.y 1/5] vxlan: flush fdb entries on oper down
Date: Fri, 20 Jan 2017 23:40:06 -0800
Message-ID: <1484984410-3304-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, ramanb@cumulusnetworks.com,
        stephen@networkplumber.org, jbenc@redhat.com, pshelar@ovn.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34468 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750800AbdAUHlG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 02:41:06 -0500
Received: by mail-pf0-f169.google.com with SMTP id e4so28012994pfg.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 23:40:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balakrishnan Raman <ramanb@cumulusnetworks.com>

Flush fdb entries of a vxlan device when its state
changes to oper down. vxlan_stop handles flush on
admin down.

Signed-off-by: Balakrishnan Raman <ramanb@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/vxlan.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 19b1653..15b1c23 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -3276,6 +3276,12 @@ static int vxlan_netdevice_event(struct notifier_block *unused,
 		vxlan_handle_lowerdev_unregister(vn, dev);
 	else if (event == NETDEV_UDP_TUNNEL_PUSH_INFO)
 		vxlan_push_rx_ports(dev);
+	else if (event == NETDEV_CHANGE) {
+		if (dev->netdev_ops == &vxlan_netdev_ops) {
+			if (netif_running(dev) && !netif_oper_up(dev))
+				vxlan_flush(netdev_priv(dev));
+		}
+	}
 
 	return NOTIFY_DONE;
 }
-- 
1.9.1
