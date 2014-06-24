From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 6/6] amd-xgbe: Resolve checkpatch warning about
 sscanf usage
Date: Tue, 24 Jun 2014 16:19:35 -0500
Message-ID: <20140624211935.20681.85586.stgit@tlendack-t1.amdoffice.net>
References: <20140624211900.20681.46554.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [207.46.163.141] ([207.46.163.141]:39024 "EHLO
	na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752809AbaFXVT5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 17:19:57 -0400
In-Reply-To: <20140624211900.20681.46554.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checkpatch issued a warning preferring to use kstrto<type> when
using a single variable sscanf.  Change the sscanf invocation to
a kstrtouint call.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
index 6bb76d5..8119858 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
@@ -151,7 +151,7 @@ static ssize_t xgbe_common_write(const char __user *buffer, size_t count,
 {
 	char workarea[32];
 	ssize_t len;
-	unsigned int scan_value;
+	int ret;
 
 	if (*ppos != 0)
 		return 0;
@@ -165,10 +165,9 @@ static ssize_t xgbe_common_write(const char __user *buffer, size_t count,
 		return len;
 
 	workarea[len] = '\0';
-	if (sscanf(workarea, "%x", &scan_value) == 1)
-		*value = scan_value;
-	else
-		return -EIO;
+	ret = kstrtouint(workarea, 0, value);
+	if (ret)
+		return ret;
 
 	return len;
 }
