From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH] net: ti cpsw ethernet: set IFCTL_A bit in MACCONTROL
Date: Thu, 27 Sep 2012 13:50:36 +0200
Message-ID: <1348746636-24156-1-git-send-email-zonque@gmail.com>
Cc: Daniel Mack <zonque@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Vaibhav Hiremath <hvaibhav@ti.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:34243 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750793Ab2I0Luw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2012 07:50:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For RMII/RGMII mode operation in 100Mbps, the CPSW needs to set the
IFCTL_A bits in the MACCONTROL register. For all other PHY modes, this
bit is unused, so setting it unconditionally shouldn't cause any
trouble.

Signed-off-by: Daniel Mack <zonque@gmail.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Cc: Vaibhav Hiremath <hvaibhav@ti.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/ti/cpsw.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index aa78168..b764f75 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -386,6 +386,11 @@ static void _cpsw_adjust_link(struct cpsw_slave *slave,
 			mac_control |= BIT(7);	/* GIGABITEN	*/
 		if (phy->duplex)
 			mac_control |= BIT(0);	/* FULLDUPLEXEN	*/
+
+		/* set speed_in input in case RMII mode is used in >10Mbps */
+		if (phy->speed > 10)
+			mac_control |= BIT(15);
+
 		*link = true;
 	} else {
 		mac_control = 0;
-- 
1.7.11.4
