From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 1/7] be2net: don't call vid_config() when there's no vlan config
Date: Wed, 6 Jun 2012 11:07:17 +0530
Message-ID: <9e61e8da-5c37-448c-8c07-71fa8b81fb5c@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:2015 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751231Ab2FFFwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 01:52:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

be_vid_config() is called from be_setup() to replay config cmds after
a card reset. Skip calling it when no vlans are configured.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 08efd30..f1b0926 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2762,7 +2762,8 @@ static int be_setup(struct be_adapter *adapter)
 
 	be_cmd_get_fw_ver(adapter, adapter->fw_ver, NULL);
 
-	be_vid_config(adapter, false, 0);
+	if (adapter->vlans_added)
+		be_vid_config(adapter, false, 0);
 
 	be_set_rx_mode(adapter->netdev);
 
-- 
1.7.4
