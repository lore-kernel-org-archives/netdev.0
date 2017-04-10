From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: save tid while creating server filter
Date: Mon, 10 Apr 2017 21:26:18 +0530
Message-ID: <1491839778-8506-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, rajur@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:23580 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753832AbdDJP40 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 11:56:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Save the filter tid while creating the server filter, which is used
later to retrieve the corresponding filter instance while handling
the filter reply.

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index afb0967..aa71019 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2338,6 +2338,10 @@ int cxgb4_create_server_filter(const struct net_device *dev, unsigned int stid,
 	f->locked = 1;
 	f->fs.rpttid = 1;
 
+	/* Save the actual tid. We need this to get the corresponding
+	 * filter entry structure in filter_rpl.
+	 */
+	f->tid = stid + adap->tids.ftid_base;
 	ret = set_filter_wr(adap, stid);
 	if (ret) {
 		clear_filter(adap, f);
-- 
2.1.0
