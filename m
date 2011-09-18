From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH 2/4] net/fec: fix fec1 check in fec_enet_mii_init()
Date: Sun, 18 Sep 2011 19:54:10 +0800
Message-ID: <1316346852-17090-3-git-send-email-shawn.guo@linaro.org>
References: <1316346852-17090-1-git-send-email-shawn.guo@linaro.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, patches@linaro.org,
	Shawn Guo <shawn.guo@linaro.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:48130 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573Ab1IRLwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2011 07:52:33 -0400
Received: by mail-pz0-f42.google.com with SMTP id 1so7732480pzk.1
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2011 04:52:33 -0700 (PDT)
In-Reply-To: <1316346852-17090-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In function fec_enet_mii_init(), it uses non-zero pdev->id as part
of the condition to check the second fec instance (fec1).  This works
before the driver supports device tree probe.  But in case of device
tree probe, pdev->id is -1 which is also non-zero, so the logic becomes
broken when device tree probe gets supported.

The patch change the logic to check "pdev->id > 0" as the part of the
condition for identifying fec1.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/fec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 6a638e9..5ef0e34 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -996,7 +996,7 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	 * mdio interface in board design, and need to be configured by
 	 * fec0 mii_bus.
 	 */
-	if ((id_entry->driver_data & FEC_QUIRK_ENET_MAC) && pdev->id) {
+	if ((id_entry->driver_data & FEC_QUIRK_ENET_MAC) && pdev->id > 0) {
 		/* fec1 uses fec0 mii_bus */
 		fep->mii_bus = fec0_mii_bus;
 		return 0;
-- 
1.7.4.1
