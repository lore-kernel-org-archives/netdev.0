From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4vf: Initialize mdio_addr before using it
Date: Mon, 12 Jan 2015 22:06:16 +0530
Message-ID: <1421080576-30885-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:5406 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752108AbbALQah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 11:30:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 5ad24def21b205a8 ("cxgb4vf: Fix ethtool get_settings for VF driver")
mdio_addr of port_info structure was used unininitialzed. Fixing it.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 21dc9a2..60426cf 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -323,6 +323,8 @@ int t4vf_port_init(struct adapter *adapter, int pidx)
 		return v;
 
 	v = be32_to_cpu(port_rpl.u.info.lstatus_to_modtype);
+	pi->mdio_addr = (v & FW_PORT_CMD_MDIOCAP_F) ?
+			FW_PORT_CMD_MDIOADDR_G(v) : -1;
 	pi->port_type = FW_PORT_CMD_PTYPE_G(v);
 	pi->mod_type = FW_PORT_MOD_TYPE_NA;
 
-- 
1.7.1
