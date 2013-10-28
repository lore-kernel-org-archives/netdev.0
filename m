From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH v2 2/2] net/benet: Make lancer_wait_ready() static
Date: Mon, 28 Oct 2013 10:12:47 +0800
Message-ID: <1382926367-14968-2-git-send-email-shangw@linux.vnet.ibm.com>
References: <1382926367-14968-1-git-send-email-shangw@linux.vnet.ibm.com>
Cc: Sathya.Perla@emulex.com, davem@davemloft.net,
	Gavin Shan <shangw@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:36745 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754546Ab3J1CNH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Oct 2013 22:13:07 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <shangw@linux.vnet.ibm.com>;
	Sun, 27 Oct 2013 22:13:06 -0400
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 49DED38C804F
	for <netdev@vger.kernel.org>; Sun, 27 Oct 2013 22:13:03 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9S2D4vq60817544
	for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 02:13:04 GMT
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r9S2D30h010484
	for <netdev@vger.kernel.org>; Sun, 27 Oct 2013 22:13:03 -0400
In-Reply-To: <1382926367-14968-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function needn't to be public, so to make it as static.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    2 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h |    1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index c08fd32..c30ab8f 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -522,7 +522,7 @@ static u16 be_POST_stage_get(struct be_adapter *adapter)
 	return sem & POST_STAGE_MASK;
 }
 
-int lancer_wait_ready(struct be_adapter *adapter)
+static int lancer_wait_ready(struct be_adapter *adapter)
 {
 #define SLIPORT_READY_TIMEOUT 30
 	u32 sliport_status;
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 108ca8a..dd522b0 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1983,7 +1983,6 @@ extern int be_cmd_get_ext_fat_capabilites(struct be_adapter *adapter,
 extern int be_cmd_set_ext_fat_capabilites(struct be_adapter *adapter,
 					  struct be_dma_mem *cmd,
 					  struct be_fat_conf_params *cfgs);
-extern int lancer_wait_ready(struct be_adapter *adapter);
 extern int lancer_physdev_ctrl(struct be_adapter *adapter, u32 mask);
 extern int lancer_initiate_dump(struct be_adapter *adapter);
 extern bool dump_present(struct be_adapter *adapter);
-- 
1.7.9.5
