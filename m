From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v2 2/3] bond: add support for ndo_switch_port_stp_update when bond is a bridge port
Date: Thu, 12 Mar 2015 17:29:57 -0700
Message-ID: <1426206598-29410-3-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: sfeldma@gmail.com, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33400 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037AbbCMAaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 20:30:10 -0400
Received: by padet14 with SMTP id et14so24819376pad.0
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 17:30:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds support for stp state offload netdev op to support the case
where bond is a bridge port and bond slaves are switch ports.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/bonding/bond_main.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c026ce9..8ea97a2 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4038,6 +4038,9 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_fix_features	= bond_fix_features,
 	.ndo_bridge_setlink	= ndo_dflt_netdev_switch_port_bridge_setlink,
 	.ndo_bridge_dellink	= ndo_dflt_netdev_switch_port_bridge_dellink,
+#ifdef CONFIG_NET_SWITCHDEV
+	.ndo_switch_port_stp_update = ndo_dflt_netdev_switch_port_stp_update,
+#endif
 };
 
 static const struct device_type bond_type = {
-- 
1.7.10.4
