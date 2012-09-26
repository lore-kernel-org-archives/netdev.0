From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 2/2] net: ti cpsw ethernet: set IFCTL_{A,B} bits for RMII mode
Date: Wed, 26 Sep 2012 19:24:28 +0200
Message-ID: <1348680268-8194-2-git-send-email-zonque@gmail.com>
References: <1348680268-8194-1-git-send-email-zonque@gmail.com>
Cc: devicetree-discuss@lists.ozlabs.org,
	Daniel Mack <zonque@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Vaibhav Hiremath <hvaibhav@ti.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:44928 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751777Ab2IZRYj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2012 13:24:39 -0400
In-Reply-To: <1348680268-8194-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For RMII mode operation in 100Mbps, the CPSW needs to set the
IFCTL_A / IFCTL_B bits in the MACCONTROL register.

Signed-off-by: Daniel Mack <zonque@gmail.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Cc: Vaibhav Hiremath <hvaibhav@ti.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/ti/cpsw.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 3d7594e..d88dbfa 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -386,6 +386,12 @@ static void _cpsw_adjust_link(struct cpsw_slave *slave,
 			mac_control |= BIT(7);	/* GIGABITEN	*/
 		if (phy->duplex)
 			mac_control |= BIT(0);	/* FULLDUPLEXEN	*/
+
+		/* set speed_in input in case RMII mode is used in >10Mbps */
+		if (phy->speed > 10 && slave->slave_num < 2 &&
+		    phy->interface == PHY_INTERFACE_MODE_RMII)
+			mac_control |= BIT(15 + slave->slave_num);
+
 		*link = true;
 	} else {
 		mac_control = 0;
-- 
1.7.11.4
