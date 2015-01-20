From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 7/7] be2net: Fix TX rate limiting on Lancer/Skyhawk-R VFs
Date: Tue, 20 Jan 2015 03:51:49 -0500
Message-ID: <1421743909-14716-8-git-send-email-sathya.perla@emulex.com>
References: <1421743909-14716-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:42761 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbbATItK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 03:49:10 -0500
In-Reply-To: <1421743909-14716-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

When max_tx_rate is set via bw_max in the NIC resource desc, bw_min must be
set to 0.
Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 2021eb0..4bd425e 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -3756,6 +3756,7 @@ int be_cmd_config_qos(struct be_adapter *adapter, u32 max_rate, u16 link_speed,
 	be_reset_nic_desc(&nic_desc);
 	nic_desc.pf_num = adapter->pf_number;
 	nic_desc.vf_num = domain;
+	nic_desc.bw_min = 0;
 	if (lancer_chip(adapter)) {
 		nic_desc.hdr.desc_type = NIC_RESOURCE_DESC_TYPE_V0;
 		nic_desc.hdr.desc_len = RESOURCE_DESC_SIZE_V0;
-- 
2.2.0
