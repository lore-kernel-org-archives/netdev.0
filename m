From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 1/5] amd-xgbe: Fix debugfs compatibility change with
 kstrtouint
Date: Wed, 2 Jul 2014 13:04:28 -0500
Message-ID: <20140702180428.14996.63518.stgit@tlendack-t1.amdoffice.net>
References: <20140702180422.14996.88116.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0238.outbound.protection.outlook.com ([207.46.163.238]:41539
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757294AbaGBSEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 14:04:32 -0400
In-Reply-To: <20140702180422.14996.88116.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The initial change from sscanf to kstrtouint broke backward
compatbility by using a base of "0" in the kstrtouint call.
This allowed for entering decimal, hexadecimal or octal as
input where previously the sscanf always interpreted the input
as hexadecimal.  Additionally, -EIO was returned on error prior
to this change and now it is whatever the error value that is
returned by kstrtouint.

Change the base value of the kstrtouint from 0 to 16 and return
-EIO on error.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
Reported-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
index 8119858..346592d 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
@@ -165,9 +165,9 @@ static ssize_t xgbe_common_write(const char __user *buffer, size_t count,
 		return len;
 
 	workarea[len] = '\0';
-	ret = kstrtouint(workarea, 0, value);
+	ret = kstrtouint(workarea, 16, value);
 	if (ret)
-		return ret;
+		return -EIO;
 
 	return len;
 }
