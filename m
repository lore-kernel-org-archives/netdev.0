From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/3] cxgb4: Decode the firmware port and module type a bit more for ethtool
Date: Wed, 7 May 2014 18:01:02 +0530
Message-ID: <1399465864-17737-2-git-send-email-hariprasad@chelsio.com>
References: <1399465864-17737-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <dm@chelsio.com>, <leedom@chelsio.com>,
	<kumaras@chelsio.com>, <nirranjan@chelsio.com>,
	<santosh@chelsio.com>, Hariprasad Shenai <hariprasad@chelsio.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4475 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026AbaEGM3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 08:29:33 -0400
In-Reply-To: <1399465864-17737-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 6fe5891..bf5eb33 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2252,12 +2252,19 @@ static int get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	else if (p->port_type == FW_PORT_TYPE_FIBER_XFI ||
 		 p->port_type == FW_PORT_TYPE_FIBER_XAUI)
 		cmd->port = PORT_FIBRE;
-	else if (p->port_type == FW_PORT_TYPE_SFP) {
-		if (p->mod_type == FW_PORT_MOD_TYPE_TWINAX_PASSIVE ||
-		    p->mod_type == FW_PORT_MOD_TYPE_TWINAX_ACTIVE)
+	else if (p->port_type == FW_PORT_TYPE_SFP ||
+		 p->port_type == FW_PORT_TYPE_QSFP_10G ||
+		 p->port_type == FW_PORT_TYPE_QSFP) {
+		if (p->mod_type == FW_PORT_MOD_TYPE_LR ||
+		    p->mod_type == FW_PORT_MOD_TYPE_SR ||
+		    p->mod_type == FW_PORT_MOD_TYPE_ER ||
+		    p->mod_type == FW_PORT_MOD_TYPE_LRM)
+			cmd->port = PORT_FIBRE;
+		else if (p->mod_type == FW_PORT_MOD_TYPE_TWINAX_PASSIVE ||
+			 p->mod_type == FW_PORT_MOD_TYPE_TWINAX_ACTIVE)
 			cmd->port = PORT_DA;
 		else
-			cmd->port = PORT_FIBRE;
+			cmd->port = PORT_OTHER;
 	} else
 		cmd->port = PORT_OTHER;
 
-- 
1.8.4
