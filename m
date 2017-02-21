From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 1/3] bnxt_en: Reject driver probe against all bridge devices
Date: Mon, 20 Feb 2017 19:25:16 -0500
Message-ID: <1487636718-21293-2-git-send-email-michael.chan@broadcom.com>
References: <1487636718-21293-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:36119 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751049AbdBUAZg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 19:25:36 -0500
Received: by mail-qk0-f180.google.com with SMTP id x71so43447706qkb.3
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 16:25:35 -0800 (PST)
In-Reply-To: <1487636718-21293-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ray Jui <ray.jui@broadcom.com>

There are additional SoC devices that use the same device ID for
bridge and NIC devices.  The bnxt driver should reject probe against
all bridge devices since it's meant to be used with only endpoint
devices.

Signed-off-by: Ray Jui <ray.jui@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 71f9a18..f4dec1b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7400,7 +7400,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct bnxt *bp;
 	int rc, max_irqs;
 
-	if (pdev->device == 0x16cd && pci_is_bridge(pdev))
+	if (pci_is_bridge(pdev))
 		return -ENODEV;
 
 	if (version_printed++ == 0)
-- 
1.8.3.1
