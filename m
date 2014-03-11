From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 3/7] be2net: log LPVID used in multi-channel configs
Date: Tue, 11 Mar 2014 18:53:05 +0530
Message-ID: <1394544189-20277-4-git-send-email-sathya.perla@emulex.com>
References: <1394544189-20277-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:37773 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753555AbaCKNUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 09:20:01 -0400
In-Reply-To: <1394544189-20277-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ravikumar Nelavelli <ravikumar.nelavelli@emulex.com>

Signed-off-by: Ravikumar Nelavelli <ravikumar.nelavelli@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index ff353d7..cf5afe7 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -244,10 +244,12 @@ static void be_async_grp5_qos_speed_process(struct be_adapter *adapter,
 static void be_async_grp5_pvid_state_process(struct be_adapter *adapter,
 		struct be_async_event_grp5_pvid_state *evt)
 {
-	if (evt->enabled)
+	if (evt->enabled) {
 		adapter->pvid = le16_to_cpu(evt->tag) & VLAN_VID_MASK;
-	else
+		dev_info(&adapter->pdev->dev, "LPVID: %d\n", adapter->pvid);
+	} else {
 		adapter->pvid = 0;
+	}
 }
 
 static void be_async_grp5_evt_process(struct be_adapter *adapter,
-- 
1.7.1
