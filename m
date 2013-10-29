From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH v2 2/2] net/benet: Make lancer_wait_ready() static
Date: Tue, 29 Oct 2013 17:30:57 +0800
Message-ID: <1383039057-28164-2-git-send-email-shangw@linux.vnet.ibm.com>
References: <1383039057-28164-1-git-send-email-shangw@linux.vnet.ibm.com>
Cc: Sathya.Perla@emulex.com, davem@davemloft.net,
	Gavin Shan <shangw@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:46942 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752808Ab3J2JbI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 05:31:08 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <shangw@linux.vnet.ibm.com>;
	Tue, 29 Oct 2013 05:31:07 -0400
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id BC82F6E803F
	for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 05:31:03 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9T9V5Pn52822200
	for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 09:31:05 GMT
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r9T9V4NN012404
	for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 07:31:05 -0200
In-Reply-To: <1383039057-28164-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function needn't to be public, so to make it as static.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    2 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h |    1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 2d55436..7fb0edf 100644
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
index 8870837..edf3e8a 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -2053,7 +2053,6 @@ int be_cmd_get_ext_fat_capabilites(struct be_adapter *adapter,
 int be_cmd_set_ext_fat_capabilites(struct be_adapter *adapter,
 				   struct be_dma_mem *cmd,
 				   struct be_fat_conf_params *cfgs);
-int lancer_wait_ready(struct be_adapter *adapter);
 int lancer_physdev_ctrl(struct be_adapter *adapter, u32 mask);
 int lancer_initiate_dump(struct be_adapter *adapter);
 bool dump_present(struct be_adapter *adapter);
-- 
1.7.9.5
