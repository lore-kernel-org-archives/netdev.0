From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH 2/2] can: ti hecc module : add platform specific initialization callback.
Date: Mon, 22 Feb 2010 19:06:02 +0530
Message-ID: <1266845762-7809-1-git-send-email-srk@ti.com>
Cc: anantgole@ti.com, Sriramakrishnan <srk@ti.com>
To: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:35410 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752185Ab0BVNgK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 08:36:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CAN module on AM3517 requires programming of IO expander as part
of init sequence - to enable CAN PHY. Added platform specific
init callback to handle this.

Signed-off-by: Sriramakrishnan <srk@ti.com>
Acked-by: Anant Gole <anantgole@ti.com>
---
 drivers/net/can/ti_hecc.c            |    3 +++
 include/linux/can/platform/ti_hecc.h |    1 +
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index df27d82..604147e 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -865,6 +865,9 @@ static int ti_hecc_probe(struct platform_device *pdev)
 		goto probe_exit;
 	}
 
+	if (pdata->platform_init)
+		pdata->platform_init();
+
 	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!mem) {
 		dev_err(&pdev->dev, "No mem resources\n");
diff --git a/include/linux/can/platform/ti_hecc.h b/include/linux/can/platform/ti_hecc.h
index 4688c7b..7036612 100644
--- a/include/linux/can/platform/ti_hecc.h
+++ b/include/linux/can/platform/ti_hecc.h
@@ -35,6 +35,7 @@ struct ti_hecc_platform_data {
 	u32 mbx_offset;
 	u32 int_line;
 	u32 version;
+	void (*platform_init) (void);
 };
 
 
-- 
1.6.2.4

