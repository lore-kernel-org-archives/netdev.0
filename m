From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next-2.6] be2net: Add 60 second delay to allow FAT dump completion on recovery from EEH
Date: Mon, 3 Oct 2011 23:40:57 +0530
Message-ID: <5bb8f639-e754-4e08-8b7b-9830a57e4826@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:3859 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755722Ab1JCMnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 08:43:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add 60s delay before timeout on polling Bit 31 so that FAT dump can
complete when reset occurs.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 38c9222..6e7b521 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -416,7 +416,7 @@ int be_cmd_POST(struct be_adapter *adapter)
 		} else {
 			return 0;
 		}
-	} while (timeout < 40);
+	} while (timeout < 60);
 
 	dev_err(dev, "POST timeout; stage=0x%x\n", stage);
 	return -1;
-- 
1.5.6.1
