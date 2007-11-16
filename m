From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 5/9] cxgb3 - FW upgrade
Date: Fri, 16 Nov 2007 11:22:00 -0800
Message-ID: <20071116192200.31097.72325.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com,
	wenxiong@us.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:5140 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765770AbXKPTWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 14:22:07 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Bump up FW version to 5.0.
Do not downgrade FW within the same major version range.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/t3_hw.c   |   10 +++++++---
 drivers/net/cxgb3/version.h |    4 ++--
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index d4ee00d..4b6087a 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -988,13 +988,17 @@ int t3_check_fw_version(struct adapter *adapter, int *must_load)
 		CH_ERR(adapter, "found wrong FW version(%u.%u), "
 		       "driver needs version %u.%u\n", major, minor,
 		       FW_VERSION_MAJOR, FW_VERSION_MINOR);
-	else {
+	else if (minor < FW_VERSION_MINOR) {
 		*must_load = 0;
-		CH_WARN(adapter, "found wrong FW minor version(%u.%u), "
+		CH_WARN(adapter, "found old FW minor version(%u.%u), "
+		        "driver compiled for version %u.%u\n", major, minor,
+			FW_VERSION_MAJOR, FW_VERSION_MINOR);
+	} else {
+		CH_WARN(adapter, "found newer FW version(%u.%u), "
 		        "driver compiled for version %u.%u\n", major, minor,
 			FW_VERSION_MAJOR, FW_VERSION_MINOR);
+			return 0;
 	}
-
 	return -EINVAL;
 }
 
diff --git a/drivers/net/cxgb3/version.h b/drivers/net/cxgb3/version.h
index ef1c633..229303f 100644
--- a/drivers/net/cxgb3/version.h
+++ b/drivers/net/cxgb3/version.h
@@ -38,7 +38,7 @@
 #define DRV_VERSION "1.0-ko"
 
 /* Firmware version */
-#define FW_VERSION_MAJOR 4
-#define FW_VERSION_MINOR 6
+#define FW_VERSION_MAJOR 5
+#define FW_VERSION_MINOR 0
 #define FW_VERSION_MICRO 0
 #endif				/* __CHELSIO_VERSION_H */
