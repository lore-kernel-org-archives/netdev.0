From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 2/2] be2net: Ignore physical link async event for Lancer
Date: Wed, 18 Jul 2012 18:22:15 +0530
Message-ID: <33934390-2e19-4782-a793-06dc2efd8d35@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:20882 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754409Ab2GRMxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 08:53:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ability of driver to transmit packets depends on logical state
of the link. Ignore physical link status.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    5 +++++
 drivers/net/ethernet/emulex/benet/be_cmds.h |    1 +
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 7932490..7fac97b 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -141,6 +141,11 @@ static void be_async_link_state_process(struct be_adapter *adapter,
 	/* When link status changes, link speed must be re-queried from FW */
 	adapter->phy.link_speed = -1;
 
+	/* Ignore physical link event */
+	if (lancer_chip(adapter) &&
+	    !(evt->port_link_status & LOGICAL_LINK_STATUS_MASK))
+		return;
+
 	/* For the initial link status do not rely on the ASYNC event as
 	 * it may not be received in some cases.
 	 */
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index d5a4ded..250f19b 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -93,6 +93,7 @@ enum {
 	LINK_UP		= 0x1
 };
 #define LINK_STATUS_MASK			0x1
+#define LOGICAL_LINK_STATUS_MASK		0x2
 
 /* When the event code of an async trailer is link-state, the mcc_compl
  * must be interpreted as follows
-- 
1.6.0.2
