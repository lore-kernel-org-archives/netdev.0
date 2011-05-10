From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 3/5] be2net: In case of UE, do not dump registers for Lancer
Date: Tue, 10 May 2011 20:43:01 +0530
Message-ID: <ade297e7-780f-4dd1-bd4a-abbf4c5ffdb3@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:11258 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752886Ab1EJPN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 11:13:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of UE, do not dump registers for Lancer as they are not
supported.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/benet/be_cmds.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 77dc157..20a97a8 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -293,7 +293,8 @@ static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
 
 		if (msecs > 4000) {
 			dev_err(&adapter->pdev->dev, "mbox poll timed out\n");
-			be_detect_dump_ue(adapter);
+			if (!lancer_chip(adapter))
+				be_detect_dump_ue(adapter);
 			return -1;
 		}
 
-- 
1.6.0.2

