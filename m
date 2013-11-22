From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 2/3] be2net: set coalesce-wm in CQ_CREATE_V2 cmd
Date: Fri, 22 Nov 2013 12:51:20 -0600
Message-ID: <20131122185120.GA4165@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:23730 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755334Ab3KVSvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 13:51:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not being set currently. (This field is not applicable for Lancer)

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index dbcd526..e0e8bc1 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1032,6 +1032,13 @@ int be_cmd_cq_create(struct be_adapter *adapter, struct be_queue_info *cq,
 	} else {
 		req->hdr.version = 2;
 		req->page_size = 1; /* 1 for 4K */
+
+		/* coalesce-wm field in this cmd is not relevant to Lancer.
+		 * Lancer uses COMMON_MODIFY_CQ to set this field
+		 */
+		if (!lancer_chip(adapter))
+			AMAP_SET_BITS(struct amap_cq_context_v2, coalescwm,
+				      ctxt, coalesce_wm);
 		AMAP_SET_BITS(struct amap_cq_context_v2, nodelay, ctxt,
 								no_delay);
 		AMAP_SET_BITS(struct amap_cq_context_v2, count, ctxt,
-- 
1.8.1.2
