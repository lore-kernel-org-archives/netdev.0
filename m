From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next] be2net: do external loopback test only when it is requested
Date: Tue,  4 Mar 2014 19:04:55 +0100
Message-ID: <1393956295-25436-1-git-send-email-ivecera@redhat.com>
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25472 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753356AbaCDSFA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2014 13:05:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: sathya.perla@emulex.com
Cc: subbu.seetharaman@emulex.com
Cc: ajit.khaparde@emulex.com

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index cf09d8f..957848f 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -809,9 +809,12 @@ be_self_test(struct net_device *netdev, struct ethtool_test *test, u64 *data)
 						&data[1]) != 0) {
 			test->flags |= ETH_TEST_FL_FAILED;
 		}
-		if (be_loopback_test(adapter, BE_ONE_PORT_EXT_LOOPBACK,
-						&data[2]) != 0) {
-			test->flags |= ETH_TEST_FL_FAILED;
+		if (test->flags & ETH_TEST_FL_EXTERNAL_LB) {
+			if (be_loopback_test(adapter, BE_ONE_PORT_EXT_LOOPBACK,
+					     &data[2]) != 0) {
+				test->flags |= ETH_TEST_FL_FAILED;
+			}
+			test->flags |= ETH_TEST_FL_EXTERNAL_LB_DONE;
 		}
 	}
 
-- 
1.8.3.2
