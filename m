From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH net-next] netxen: explicity handle pause autoneg parameter
Date: Fri, 26 Oct 2012 15:17:12 -0200
Message-ID: <1351271832-21275-1-git-send-email-fbl@redhat.com>
Cc: Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27248 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756648Ab2JZRR1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 13:17:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hardware doesn't support controlling pause frames autoneg, so
report that back correctly to userspace.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c | 6 ++++++
 1 file changed, 6 insertions(+)

I don't have the hardware handy to test this, so I appreciate
if someone could do it.

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
index 10468e7..b4b46f9 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
@@ -488,6 +488,8 @@ netxen_nic_get_pauseparam(struct net_device *dev,
 	__u32 val;
 	int port = adapter->physical_port;
 
+	pause->autoneg = AUTONEG_DISABLE;
+
 	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
 		if ((port < 0) || (port >= NETXEN_NIU_MAX_GBE_PORTS))
 			return;
@@ -532,6 +534,10 @@ netxen_nic_set_pauseparam(struct net_device *dev,
 	struct netxen_adapter *adapter = netdev_priv(dev);
 	__u32 val;
 	int port = adapter->physical_port;
+
+	if (pause->autoneg)
+		return -EOPNOTSUPP;
+
 	/* read mode */
 	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
 		if ((port < 0) || (port >= NETXEN_NIU_MAX_GBE_PORTS))
-- 
1.7.11.4
