From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 2/3] be2net: FW init cmd fix for lancer
Date: Wed, 1 Dec 2010 16:33:36 +0530
Message-ID: <20101201110336.GA1623@emulex.com>
Reply-To: Sathya Perla <sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:37748 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753874Ab0LALD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 06:03:58 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lancer can use the same pattern as BE to indicate a driver load
to the FW.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_cmds.c |   27 ++++++++-------------------
 1 files changed, 8 insertions(+), 19 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 3865b2b..31c5ddc 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -470,25 +470,14 @@ int be_cmd_fw_init(struct be_adapter *adapter)
 	spin_lock(&adapter->mbox_lock);
 
 	wrb = (u8 *)wrb_from_mbox(adapter);
-	if (lancer_chip(adapter)) {
-		*wrb++ = 0xFF;
-		*wrb++ = 0x34;
-		*wrb++ = 0x12;
-		*wrb++ = 0xFF;
-		*wrb++ = 0xFF;
-		*wrb++ = 0x78;
-		*wrb++ = 0x56;
-		*wrb = 0xFF;
-	} else {
-		*wrb++ = 0xFF;
-		*wrb++ = 0x12;
-		*wrb++ = 0x34;
-		*wrb++ = 0xFF;
-		*wrb++ = 0xFF;
-		*wrb++ = 0x56;
-		*wrb++ = 0x78;
-		*wrb = 0xFF;
-	}
+	*wrb++ = 0xFF;
+	*wrb++ = 0x12;
+	*wrb++ = 0x34;
+	*wrb++ = 0xFF;
+	*wrb++ = 0xFF;
+	*wrb++ = 0x56;
+	*wrb++ = 0x78;
+	*wrb = 0xFF;
 
 	status = be_mbox_notify_wait(adapter);
 
-- 
1.6.5.2

