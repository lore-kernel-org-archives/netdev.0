From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH next 4/6] be2net: call ENABLE_VF cmd for Skyhawk-R too
Date: Tue, 1 Oct 2013 15:59:59 +0530
Message-ID: <1380623401-15630-5-git-send-email-sathya.perla@emulex.com>
References: <1380623401-15630-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:37810 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115Ab3JAK0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 06:26:33 -0400
In-Reply-To: <1380623401-15630-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

This cmd needs to be sent to FW when enabling VFs (currently used only
for Lancer.) Also, avoid calling the cmd when driver loads and finds that
VFs are already enabled from a previous load.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 331dfdc..8610530 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -3511,7 +3511,7 @@ int be_cmd_enable_vf(struct be_adapter *adapter, u8 domain)
 	struct be_cmd_enable_disable_vf *req;
 	int status;
 
-	if (!lancer_chip(adapter))
+	if (BEx_chip(adapter))
 		return 0;
 
 	spin_lock_bh(&adapter->mcc_lock);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index be12987..961e9f0 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2923,7 +2923,8 @@ static int be_vf_setup(struct be_adapter *adapter)
 			goto err;
 		vf_cfg->def_vid = def_vlan;
 
-		be_cmd_enable_vf(adapter, vf + 1);
+		if (!old_vfs)
+			be_cmd_enable_vf(adapter, vf + 1);
 	}
 
 	if (!old_vfs) {
-- 
1.7.1
