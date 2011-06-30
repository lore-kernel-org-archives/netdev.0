From: amit.salecha@qlogic.com
Subject: [PATCHv2 NEXT 1/2] net: add external loopback test in ethtool self test
Date: Wed, 29 Jun 2011 23:00:49 -0700
Message-ID: <1309413650-15952-2-git-send-email-amit.salecha@qlogic.com>
References: <1309413650-15952-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	sucheta.chakraborty@qlogic.com,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:53597 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1752586Ab1F3GJO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2011 02:09:14 -0400
In-Reply-To: <1309413650-15952-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

External loopback test can be performed by application without any driver
support on normal Ethernet cards.
But on CNA devices, where multiple functions share same physical port.
Here internal loopback test and external loopback test can be initiated by
multiple functions at same time. To co exist all functions, firmware need
to regulate what test can be run by which function. So before performing external
loopback test, command need to send to firmware, which will quiescent other functions.

User may not want to run external loopback test always. As special cable need to be
connected for this test.
So adding explicit flag in ethtool self test, which will specify interface
to perform external loopback test.
 ETH_TEST_FL_EXTERNAL_LB: Application set to request external loopback test
 ETH_TEST_FL_EXTERNAL_LB_DONE: Driver ack if test performed

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 include/linux/ethtool.h |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 048d0fa..c6e427a 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -310,9 +310,21 @@ struct ethtool_sset_info {
 				   __u32's, etc. */
 };
 
+/**
+ * enum ethtool_test_flags - flags definition of ethtool_test
+ * @ETH_TEST_FL_OFFLINE: if set perform online and offline tests, otherwise
+ *	only online tests.
+ * @ETH_TEST_FL_FAILED: Driver set this flag if test fails.
+ * @ETH_TEST_FL_EXTERNAL_LB: Application request to perform external loopback
+ *	test.
+ * @ETH_TEST_FL_EXTERNAL_LB_DONE: Driver performed the external loopback test
+ */
+
 enum ethtool_test_flags {
-	ETH_TEST_FL_OFFLINE	= (1 << 0),	/* online / offline */
-	ETH_TEST_FL_FAILED	= (1 << 1),	/* test passed / failed */
+	ETH_TEST_FL_OFFLINE	= (1 << 0),
+	ETH_TEST_FL_FAILED	= (1 << 1),
+	ETH_TEST_FL_EXTERNAL_LB	= (1 << 2),
+	ETH_TEST_FL_EXTERNAL_LB_DONE	= (1 << 3),
 };
 
 /* for requesting NIC test and getting results*/
-- 
1.7.3.3

