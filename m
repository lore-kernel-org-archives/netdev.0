From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH net-next v2] netxen: explicity handle pause autoneg parameter
Date: Fri, 26 Oct 2012 22:39:53 -0200
Message-ID: <1351298393-18172-1-git-send-email-fbl@redhat.com>
Cc: Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24459 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756284Ab2J0AkW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 20:40:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hardware doesn't support controlling pause frames autoneg, so
report that back correctly to userspace.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c | 7 +++++++
 1 file changed, 7 insertions(+)

 I don't have the hardware handy to test this, so I appreciate
 if someone could do it.

Changelog:
v2:
   fixed to not use AUTONEG_DISABLE
   fixed to return -EINVAL instead of -EOPNOTSUPP

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
index 10468e7..6bf73e1 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
@@ -488,6 +488,8 @@ netxen_nic_get_pauseparam(struct net_device *dev,
 	__u32 val;
 	int port = adapter->physical_port;
 
+	pause->autoneg = 0;
+
 	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
 		if ((port < 0) || (port >= NETXEN_NIU_MAX_GBE_PORTS))
 			return;
@@ -532,6 +534,11 @@ netxen_nic_set_pauseparam(struct net_device *dev,
 	struct netxen_adapter *adapter = netdev_priv(dev);
 	__u32 val;
 	int port = adapter->physical_port;
+
+	/* not supported */
+	if (pause->autoneg)
+		return -EINVAL;
+
 	/* read mode */
 	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
 		if ((port < 0) || (port >= NETXEN_NIU_MAX_GBE_PORTS))
-- 
1.7.11.4
