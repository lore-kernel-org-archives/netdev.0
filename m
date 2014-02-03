From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 11/13] sfc: Cosmetic changes to self-test from the
 out-of-tree driver
Date: Mon, 3 Feb 2014 23:35:52 +0000
Message-ID: <52F027D8.4010108@solarflare.com>
References: <52F02469.50302@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8220 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754082AbaBCXf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 18:35:56 -0500
In-Reply-To: <52F02469.50302@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 2294289..3444dd6 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -251,6 +251,9 @@ static void efx_fill_test(unsigned int test_index, u8 *strings, u64 *data,
  * @test_index:		Starting index of the test
  * @strings:		Ethtool strings, or %NULL
  * @data:		Ethtool test results, or %NULL
+ *
+ * Fill in a block of loopback self-test entries.  Return new test
+ * index.
  */
 static int efx_fill_loopback_test(struct efx_nic *efx,
 				  struct efx_loopback_self_tests *lb_tests,
@@ -290,6 +293,12 @@ static int efx_fill_loopback_test(struct efx_nic *efx,
  * @tests:		Efx self-test results structure, or %NULL
  * @strings:		Ethtool strings, or %NULL
  * @data:		Ethtool test results, or %NULL
+ *
+ * Get self-test number of strings, strings, and/or test results.
+ * Return number of strings (== number of test results).
+ *
+ * The reason for merging these three functions is to make sure that
+ * they can never be inconsistent.
  */
 static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
 				       struct efx_self_tests *tests,
@@ -444,7 +453,7 @@ static void efx_ethtool_self_test(struct net_device *net_dev,
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_self_tests *efx_tests;
-	int already_up;
+	bool already_up;
 	int rc = -ENOMEM;
 
 	efx_tests = kzalloc(sizeof(*efx_tests), GFP_KERNEL);
@@ -453,7 +462,7 @@ static void efx_ethtool_self_test(struct net_device *net_dev,
 
 	if (efx->state != STATE_READY) {
 		rc = -EIO;
-		goto fail1;
+		goto out;
 	}
 
 	netif_info(efx, drv, efx->net_dev, "starting %sline testing\n",
@@ -466,7 +475,7 @@ static void efx_ethtool_self_test(struct net_device *net_dev,
 		if (rc) {
 			netif_err(efx, drv, efx->net_dev,
 				  "failed opening device.\n");
-			goto fail1;
+			goto out;
 		}
 	}
 
@@ -479,8 +488,7 @@ static void efx_ethtool_self_test(struct net_device *net_dev,
 		   rc == 0 ? "passed" : "failed",
 		   (test->flags & ETH_TEST_FL_OFFLINE) ? "off" : "on");
 
-fail1:
-	/* Fill ethtool results structures */
+out:
 	efx_ethtool_fill_self_tests(efx, efx_tests, NULL, data);
 	kfree(efx_tests);
 fail:
