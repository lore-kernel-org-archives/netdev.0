From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH] be2net: hash key for rss-config cmd not set
Date: Mon, 23 May 2011 17:55:27 +0530
Message-ID: <249a7eac-6aa7-481d-b7b0-a2a3b144963f@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:6574 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753033Ab1EWM03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 08:26:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need a random hash key to effectively hash incoming connections into
multiple RX rings.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_cmds.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 2463b1c..81654ae 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1703,7 +1703,8 @@ int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable, u16 table_size)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_rss_config *req;
-	u32 myhash[10];
+	u32 myhash[10] = {0x0123, 0x4567, 0x89AB, 0xCDEF, 0x01EF,
+			0x0123, 0x4567, 0x89AB, 0xCDEF, 0x01EF};
 	int status;
 
 	if (mutex_lock_interruptible(&adapter->mbox_lock))
-- 
1.7.4

