From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next-2.6 2/4] be2net: Fixed Endianness issues in the response read log length field while retrieving FAT data
Date: Fri, 30 Sep 2011 22:54:00 +0530
Message-ID: <a2558d45-af40-4b45-b5cd-2e906eda06fb@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:10146 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758405Ab1I3MAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 08:00:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was manifesting as a crash when FAT Dump extraction was attempted on a PPC machine.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 4b655b8..15949b9 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1429,7 +1429,7 @@ void be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf)
 			struct be_cmd_resp_get_fat *resp = get_fat_cmd.va;
 			memcpy(buf + offset,
 				resp->data_buffer,
-				resp->read_log_length);
+				le32_to_cpu(resp->read_log_length));
 		} else {
 			dev_err(&adapter->pdev->dev, "FAT Table Retrieve error\n");
 			goto err;
-- 
1.5.6.1
