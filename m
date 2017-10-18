From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 3/8] cxgb4: add tc flower support for action PASS
Date: Wed, 18 Oct 2017 20:49:09 +0530
Message-ID: <09dc5b7efacdbcf8e59a85c63c3e7c36c28089e2.1508312071.git.rahul.lakkireddy@chelsio.com>
References: <cover.1508312071.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, kumaras@chelsio.com, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:35802 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdJRPUh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:20:37 -0400
In-Reply-To: <cover.1508312071.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1508312071.git.rahul.lakkireddy@chelsio.com>
References: <cover.1508312071.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Add support for tc flower action PASS.

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
index f7554b768e9d..4d4f3af20496 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
@@ -263,7 +263,9 @@ static void cxgb4_process_flow_actions(struct net_device *in,
 
 	tcf_exts_to_list(cls->exts, &actions);
 	list_for_each_entry(a, &actions, list) {
-		if (is_tcf_gact_shot(a)) {
+		if (is_tcf_gact_ok(a)) {
+			fs->action = FILTER_PASS;
+		} else if (is_tcf_gact_shot(a)) {
 			fs->action = FILTER_DROP;
 		} else if (is_tcf_mirred_egress_redirect(a)) {
 			int ifindex = tcf_mirred_ifindex(a);
@@ -306,7 +308,9 @@ static int cxgb4_validate_flow_actions(struct net_device *dev,
 
 	tcf_exts_to_list(cls->exts, &actions);
 	list_for_each_entry(a, &actions, list) {
-		if (is_tcf_gact_shot(a)) {
+		if (is_tcf_gact_ok(a)) {
+			/* Do nothing */
+		} else if (is_tcf_gact_shot(a)) {
 			/* Do nothing */
 		} else if (is_tcf_mirred_egress_redirect(a)) {
 			struct adapter *adap = netdev2adap(dev);
-- 
2.14.1
