From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 net 2/4] be2net: Implement ndo_gso_check()
Date: Thu, 13 Nov 2014 16:38:13 -0800
Message-ID: <1415925495-59312-3-git-send-email-joestringer@nicira.com>
References: <1415925495-59312-1-git-send-email-joestringer@nicira.com>
Cc: sathya.perla@emulex.com, shahed.shaikh@qlogic.com,
	amirv@mellanox.com, Dept-GELinuxNICDev@qlogic.com,
	therbert@google.com, gerlitz.or@gmail.com,
	alexander.duyck@gmail.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog111.obsmtp.com ([74.125.149.205]:40565 "HELO
	na3sys009aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S934764AbaKNAim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 19:38:42 -0500
Received: by mail-pa0-f54.google.com with SMTP id hz1so5151492pad.41
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 16:38:37 -0800 (PST)
In-Reply-To: <1415925495-59312-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use vxlan_gso_check() to advertise offload support for this NIC.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
v2: Refactor out vxlan helper.
---
 drivers/net/ethernet/emulex/benet/be_main.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9a18e79..3e8475c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4421,6 +4421,11 @@ static void be_del_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
 		 "Disabled VxLAN offloads for UDP port %d\n",
 		 be16_to_cpu(port));
 }
+
+static bool be_gso_check(struct sk_buff *skb, struct net_device *dev)
+{
+	return vxlan_gso_check(skb);
+}
 #endif
 
 static const struct net_device_ops be_netdev_ops = {
@@ -4450,6 +4455,7 @@ static const struct net_device_ops be_netdev_ops = {
 #ifdef CONFIG_BE2NET_VXLAN
 	.ndo_add_vxlan_port	= be_add_vxlan_port,
 	.ndo_del_vxlan_port	= be_del_vxlan_port,
+	.ndo_gso_check		= be_gso_check,
 #endif
 };
 
-- 
1.7.10.4
