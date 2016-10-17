From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 3/7] net: hns: Fix hns_dsaf module autoload for OF registration
Date: Mon, 17 Oct 2016 11:05:42 -0300
Message-ID: <1476713146-26632-4-git-send-email-javier@osg.samsung.com>
References: <1476713146-26632-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        netdev@vger.kernel.org, Kejian Yan <yankejian@huawei.com>,
        Daode Huang <huangdaode@hisilicon.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        "David S. Miller" <davem@davemloft.net>,
        oulijun <oulijun@huawei.com>,
        Qianqian Xie <xieqianqian@huawei.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:35544
        "EHLO s-opensource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934779AbcJQOGU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 10:06:20 -0400
In-Reply-To: <1476713146-26632-1-git-send-email-javier@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the driver is built as a module, autoload won't work because the module
alias information is not filled. So user-space can't match the registered
device with the corresponding module.

Export the module alias information using the MODULE_DEVICE_TABLE() macro.

Before this patch:

$ modinfo drivers/net/ethernet/hisilicon/hns/hns_dsaf.ko | grep alias
alias:          acpi*:HISI00B2:*
alias:          acpi*:HISI00B1:*

After this patch:

$ modinfo drivers/net/ethernet/hisilicon/hns/hns_dsaf.ko | grep alias
alias:          acpi*:HISI00B2:*
alias:          acpi*:HISI00B1:*
alias:          of:N*T*Chisilicon,hns-dsaf-v2C*
alias:          of:N*T*Chisilicon,hns-dsaf-v2
alias:          of:N*T*Chisilicon,hns-dsaf-v1C*
alias:          of:N*T*Chisilicon,hns-dsaf-v1

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 8d70377f6624..8ea3d95fa483 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -2751,6 +2751,7 @@ static const struct of_device_id g_dsaf_match[] = {
 	{.compatible = "hisilicon,hns-dsaf-v2"},
 	{}
 };
+MODULE_DEVICE_TABLE(of, g_dsaf_match);
 
 static struct platform_driver g_dsaf_driver = {
 	.probe = hns_dsaf_probe,
-- 
2.7.4
