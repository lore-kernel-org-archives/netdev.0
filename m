From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 4/7] net: qcom/emac: Fix module autoload for OF registration
Date: Mon, 17 Oct 2016 11:05:43 -0300
Message-ID: <1476713146-26632-5-git-send-email-javier@osg.samsung.com>
References: <1476713146-26632-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        netdev@vger.kernel.org, Timur Tabi <timur@codeaurora.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:35541
        "EHLO s-opensource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934706AbcJQOGU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 10:06:20 -0400
In-Reply-To: <1476713146-26632-1-git-send-email-javier@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the driver is built as a module, autoload won't work because the module
alias information is not filled. So user-space can't match the registered
device with the corresponding module.

Export the module alias information using the MODULE_DEVICE_TABLE() macro.

Before this patch:

$ modinfo drivers/net/ethernet/qualcomm/emac/qcom-emac.ko | grep alias
alias:          platform:qcom-emac

After this patch:

$ modinfo drivers/net/ethernet/qualcomm/emac/qcom-emac.ko | grep alias
alias:          platform:qcom-emac
alias:          of:N*T*Cqcom,fsm9900-emacC*
alias:          of:N*T*Cqcom,fsm9900-emac

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/ethernet/qualcomm/emac/emac.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index 9bf3b2b82e95..4fede4b86538 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -575,6 +575,7 @@ static const struct of_device_id emac_dt_match[] = {
 	},
 	{}
 };
+MODULE_DEVICE_TABLE(of, emac_dt_match);
 
 #if IS_ENABLED(CONFIG_ACPI)
 static const struct acpi_device_id emac_acpi_match[] = {
-- 
2.7.4
