From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 5/7] qla3xxx: Add ethtool get_pauseparam for improved bonding support.
Date: Mon, 26 Mar 2007 12:43:51 -0700
Message-ID: <11749382343691-git-send-email-ron.mercer@qlogic.com>
References: <20070326164650.GA3822@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:59437 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753735AbXCZTn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 15:43:59 -0400
In-Reply-To: <20070326164650.GA3822@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 9947a8d..631bf9f 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1624,6 +1624,23 @@ static void ql_set_msglevel(struct net_device *ndev, u32 value)
 	qdev->msg_enable = value;
 }
 
+static void ql_get_pauseparam(struct net_device *ndev,
+			      struct ethtool_pauseparam *pause)
+{
+	struct ql3_adapter *qdev = netdev_priv(ndev);
+	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+
+	u32 reg;
+	if(qdev->mac_index == 0)
+		reg = ql_read_page0_reg(qdev, &port_regs->mac0ConfigReg);
+	else
+		reg = ql_read_page0_reg(qdev, &port_regs->mac1ConfigReg);
+
+	pause->autoneg  = ql_get_auto_cfg_status(qdev);
+	pause->rx_pause = (reg & MAC_CONFIG_REG_RF) >> 2;
+	pause->tx_pause = (reg & MAC_CONFIG_REG_TF) >> 1;
+}
+
 static const struct ethtool_ops ql3xxx_ethtool_ops = {
 	.get_settings = ql_get_settings,
 	.get_drvinfo = ql_get_drvinfo,
@@ -1631,6 +1648,7 @@ static const struct ethtool_ops ql3xxx_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 	.get_msglevel = ql_get_msglevel,
 	.set_msglevel = ql_set_msglevel,
+	.get_pauseparam = ql_get_pauseparam,
 };
 
 static int ql_populate_free_queue(struct ql3_adapter *qdev)
-- 
1.5.0.rc4.16.g9e258

