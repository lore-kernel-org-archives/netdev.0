From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 5/7] net: hisilicon: Fix hns_mdio module autoload for OF registration
Date: Mon, 17 Oct 2016 11:05:44 -0300
Message-ID: <1476713146-26632-6-git-send-email-javier@osg.samsung.com>
References: <1476713146-26632-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        netdev@vger.kernel.org, Salil Mehta <salil.mehta@huawei.com>,
        Yisen Zhuang <yisen.zhuang@huawei.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:35549
        "EHLO s-opensource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934791AbcJQOGV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 10:06:21 -0400
In-Reply-To: <1476713146-26632-1-git-send-email-javier@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the driver is built as a module, autoload won't work because the module
alias information is not filled. So user-space can't match the registered
device with the corresponding module.

Export the module alias information using the MODULE_DEVICE_TABLE() macro.

Before this patch:

$ modinfo drivers/net/ethernet/hisilicon//hns_mdio.ko | grep alias
alias:          platform:Hi-HNS_MDIO
alias:          acpi*:HISI0141:*

After this patch:

$ modinfo drivers/net/ethernet/hisilicon//hns_mdio.ko | grep alias
alias:          platform:Hi-HNS_MDIO
alias:          of:N*T*Chisilicon,hns-mdioC*
alias:          of:N*T*Chisilicon,hns-mdio
alias:          of:N*T*Chisilicon,mdioC*
alias:          of:N*T*Chisilicon,mdio
alias:          acpi*:HISI0141:*

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/ethernet/hisilicon/hns_mdio.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/hisilicon/hns_mdio.c b/drivers/net/ethernet/hisilicon/hns_mdio.c
index 33f4c483af0f..501eb2090ca6 100644
--- a/drivers/net/ethernet/hisilicon/hns_mdio.c
+++ b/drivers/net/ethernet/hisilicon/hns_mdio.c
@@ -563,6 +563,7 @@ static const struct of_device_id hns_mdio_match[] = {
 	{.compatible = "hisilicon,hns-mdio"},
 	{}
 };
+MODULE_DEVICE_TABLE(of, hns_mdio_match);
 
 static const struct acpi_device_id hns_mdio_acpi_match[] = {
 	{ "HISI0141", 0 },
-- 
2.7.4
