From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 4/5] qlcnic: remove fw version check
Date: Thu, 16 Sep 2010 22:14:42 -0700
Message-ID: <1284700483-16397-5-git-send-email-amit.salecha@qlogic.com>
References: <1284700483-16397-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:45126 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750860Ab0IQFOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Sep 2010 01:14:44 -0400
In-Reply-To: <1284700483-16397-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't compare flash and file fw version. Allow to load
old fw from file than flashed fw.
If file fw is present, don't skip fw re-intialization.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_init.c |   30 ++----------------------------
 1 files changed, 2 insertions(+), 28 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 9f994b9..e26fa95 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1015,8 +1015,6 @@ qlcnic_check_fw_hearbeat(struct qlcnic_adapter *adapter)
 int
 qlcnic_need_fw_reset(struct qlcnic_adapter *adapter)
 {
-	u32 val, version, major, minor, build;
-
 	if (qlcnic_check_fw_hearbeat(adapter)) {
 		qlcnic_rom_lock_recovery(adapter);
 		return 1;
@@ -1025,20 +1023,8 @@ qlcnic_need_fw_reset(struct qlcnic_adapter *adapter)
 	if (adapter->need_fw_reset)
 		return 1;
 
-	/* check if we have got newer or different file firmware */
-	if (adapter->fw) {
-
-		val = qlcnic_get_fw_version(adapter);
-
-		version = QLCNIC_DECODE_VERSION(val);
-
-		major = QLCRD32(adapter, QLCNIC_FW_VERSION_MAJOR);
-		minor = QLCRD32(adapter, QLCNIC_FW_VERSION_MINOR);
-		build = QLCRD32(adapter, QLCNIC_FW_VERSION_SUB);
-
-		if (version > QLCNIC_VERSION_CODE(major, minor, build))
-			return 1;
-	}
+	if (adapter->fw)
+		return 1;
 
 	return 0;
 }
@@ -1174,18 +1160,6 @@ qlcnic_validate_firmware(struct qlcnic_adapter *adapter)
 		return -EINVAL;
 	}
 
-	/* check if flashed firmware is newer */
-	if (qlcnic_rom_fast_read(adapter,
-			QLCNIC_FW_VERSION_OFFSET, (int *)&val))
-		return -EIO;
-
-	val = QLCNIC_DECODE_VERSION(val);
-	if (val > ver) {
-		dev_info(&pdev->dev, "%s: firmware is older than flash\n",
-				fw_name[fw_type]);
-		return -EINVAL;
-	}
-
 	QLCWR32(adapter, QLCNIC_CAM_RAM(0x1fc), QLCNIC_BDINFO_MAGIC);
 	return 0;
 }
-- 
1.6.0.2

