From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: fix memory leak
Date: Mon,  4 Sep 2017 11:16:28 +0530
Message-ID: <1504503988-21903-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:38520 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752632AbdIDFqq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 01:46:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

do not reuse the loop counter which is used iterate over
the ports, so that sched_tbl will be freed for all the ports.

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sched.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sched.c b/drivers/net/ethernet/chelsio/cxgb4/sched.c
index 02acff7..9148abb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sched.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sched.c
@@ -533,10 +533,10 @@ struct sched_table *t4_init_sched(unsigned int sched_size)
 void t4_cleanup_sched(struct adapter *adap)
 {
 	struct sched_table *s;
-	unsigned int i;
+	unsigned int j, i;
 
-	for_each_port(adap, i) {
-		struct port_info *pi = netdev2pinfo(adap->port[i]);
+	for_each_port(adap, j) {
+		struct port_info *pi = netdev2pinfo(adap->port[j]);
 
 		s = pi->sched_tbl;
 		for (i = 0; i < s->sched_size; i++) {
-- 
2.1.0
