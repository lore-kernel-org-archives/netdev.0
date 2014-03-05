From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next v2] be2net: do external loopback test only when it is requested
Date: Wed,  5 Mar 2014 11:54:05 +0100
Message-ID: <1394016845-5376-1-git-send-email-ivecera@redhat.com>
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, sergei.shtylyov@cogentembedded.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53175 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752331AbaCEKyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 05:54:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2: remove unnecessary braces from all 'loopback' if-blocks (thx Sergei)

Cc: sathya.perla@emulex.com
Cc: subbu.seetharaman@emulex.com
Cc: ajit.khaparde@emulex.com
Cc: sergei.shtylyov@cogentembedded.com

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index cf09d8f..66759b6 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -802,16 +802,18 @@ be_self_test(struct net_device *netdev, struct ethtool_test *test, u64 *data)
 
 	if (test->flags & ETH_TEST_FL_OFFLINE) {
 		if (be_loopback_test(adapter, BE_MAC_LOOPBACK,
-						&data[0]) != 0) {
+				     &data[0]) != 0)
 			test->flags |= ETH_TEST_FL_FAILED;
-		}
+
 		if (be_loopback_test(adapter, BE_PHY_LOOPBACK,
-						&data[1]) != 0) {
-			test->flags |= ETH_TEST_FL_FAILED;
-		}
-		if (be_loopback_test(adapter, BE_ONE_PORT_EXT_LOOPBACK,
-						&data[2]) != 0) {
+				     &data[1]) != 0)
 			test->flags |= ETH_TEST_FL_FAILED;
+
+		if (test->flags & ETH_TEST_FL_EXTERNAL_LB) {
+			if (be_loopback_test(adapter, BE_ONE_PORT_EXT_LOOPBACK,
+					     &data[2]) != 0)
+				test->flags |= ETH_TEST_FL_FAILED;
+			test->flags |= ETH_TEST_FL_EXTERNAL_LB_DONE;
 		}
 	}
 
-- 
1.8.3.2
