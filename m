From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 4/5] be2net: pass domain id to
 be_cmd_link_status_query
Date: Tue, 19 Apr 2011 17:11:46 -0500
Message-ID: <20110419221146.GA3660@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:3025 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754349Ab1DSWNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 18:13:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_cmds.c    |    2 +-
 drivers/net/benet/be_cmds.h    |    2 +-
 drivers/net/benet/be_ethtool.c |    4 ++--
 drivers/net/benet/be_main.c    |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index a94e980..af8cf3d 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1112,7 +1112,7 @@ err:
 
 /* Uses synchronous mcc */
 int be_cmd_link_status_query(struct be_adapter *adapter,
-			bool *link_up, u8 *mac_speed, u16 *link_speed)
+			bool *link_up, u8 *mac_speed, u16 *link_speed, u32 dom)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_link_status *req;
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 3fb6e0a..af4bbff 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -1112,7 +1112,7 @@ extern int be_cmd_rxq_create(struct be_adapter *adapter,
 extern int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 			int type);
 extern int be_cmd_link_status_query(struct be_adapter *adapter,
-			bool *link_up, u8 *mac_speed, u16 *link_speed);
+			bool *link_up, u8 *mac_speed, u16 *link_speed, u32 dom);
 extern int be_cmd_reset(struct be_adapter *adapter);
 extern int be_cmd_get_stats(struct be_adapter *adapter,
 			struct be_dma_mem *nonemb_cmd);
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 33c2bec..6565f3e 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -376,7 +376,7 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 
 	if ((adapter->link_speed < 0) || (!(netdev->flags & IFF_UP))) {
 		status = be_cmd_link_status_query(adapter, &link_up,
-						&mac_speed, &link_speed);
+						&mac_speed, &link_speed, 0);
 
 		be_link_status_update(adapter, link_up);
 		/* link_speed is in units of 10 Mbps */
@@ -661,7 +661,7 @@ be_self_test(struct net_device *netdev, struct ethtool_test *test, u64 *data)
 	}
 
 	if (be_cmd_link_status_query(adapter, &link_up, &mac_speed,
-				&qos_link_speed) != 0) {
+				&qos_link_speed, 0) != 0) {
 		test->flags |= ETH_TEST_FL_FAILED;
 		data[4] = -1;
 	} else if (!mac_speed) {
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 1bb763c..77a6e7e 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2171,7 +2171,7 @@ static int be_open(struct net_device *netdev)
 	be_async_mcc_enable(adapter);
 
 	status = be_cmd_link_status_query(adapter, &link_up, &mac_speed,
-			&link_speed);
+			&link_speed, 0);
 	if (status)
 		goto err;
 	be_link_status_update(adapter, link_up);
-- 
1.7.1

