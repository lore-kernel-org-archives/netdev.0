From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net v2] cxgb4 : Fix DCB priority groups being returned in wrong order
Date: Thu, 20 Nov 2014 17:11:46 -0800
Message-ID: <1416532306-29739-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:33258
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756487AbaKUBLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 20:11:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peer priority groups were being reversed, but this was missed in the previous
fix sent out for this issue.

v2 : Previous patch was doing extra unnecessary work, result is the same.
Please ignore previous patch

Fixes :	ee7bc3cdc270 ('cxgb4 : dcb open-lldp interop fixes')

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
index cca6049..4fe3360 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
@@ -1082,7 +1082,7 @@ static int cxgb4_cee_peer_getpg(struct net_device *dev, struct cee_pg *pg)
 	pgid = be32_to_cpu(pcmd.u.dcb.pgid.pgid);
 
 	for (i = 0; i < CXGB4_MAX_PRIORITY; i++)
-		pg->prio_pg[i] = (pgid >> (i * 4)) & 0xF;
+		pg->prio_pg[7 - i] = (pgid >> (i * 4)) & 0xF;
 
 	INIT_PORT_DCB_READ_PEER_CMD(pcmd, pi->port_id);
 	pcmd.u.dcb.pgrate.type = FW_PORT_DCB_TYPE_PGRATE;
-- 
2.1.3
