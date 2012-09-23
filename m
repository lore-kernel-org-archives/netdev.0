From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch v2] bnx2x: Improve code around
 bnx2x_tests_str_arr
Date: Sun, 23 Sep 2012 15:12:23 +0200
Message-ID: <1348405943-32605-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4586 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752266Ab2IWKJy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Sep 2012 06:09:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the definition of bnx2x_tests_str_arr from static char
pointer to static const char bi-directional array. Also the
bnx2x_get_strings function is simplified.

Reported-by: Joe Perches <joe@perches.com>
Reported-by: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Merav Sicron <meravs@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
Hi,
Sorry for the late response.

Changes comparing to v1: Define the content of the array const, use
bi-directional array instead of array with strings pointers, simplify the
bnx2x_get_strings function by using memcpy.

Dave, please consider applying this patch to net-next.

Thanks,
Merav

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c |   13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index f923125..a19c9e0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1607,7 +1607,7 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
 	return 0;
 }

-static char *bnx2x_tests_str_arr[BNX2X_NUM_TESTS_SF] = {
+static const char bnx2x_tests_str_arr[BNX2X_NUM_TESTS_SF][ETH_GSTRING_LEN] = {
 	"register_test (offline)    ",
 	"memory_test (offline)      ",
 	"int_loopback_test (offline)",
@@ -2536,7 +2536,7 @@ static int bnx2x_get_sset_count(struct net_device *dev, int stringset)
 static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	int i, j, k, offset, start;
+	int i, j, k, start;
 	char queue_name[MAX_QUEUE_NAME_LEN+1];

 	switch (stringset) {
@@ -2572,13 +2572,8 @@ static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 			start = 0;
 		else
 			start = 4;
-		for (i = 0, j = start; j < (start + BNX2X_NUM_TESTS(bp));
-		     i++, j++) {
-			offset = sprintf(buf+32*i, "%s",
-					 bnx2x_tests_str_arr[j]);
-			*(buf+offset) = '\0';
-		}
-		break;
+		memcpy(buf, bnx2x_tests_str_arr + start,
+		       ETH_GSTRING_LEN * BNX2X_NUM_TESTS(bp));
 	}
 }

--
1.7.10
