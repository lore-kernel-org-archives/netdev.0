From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 1/7] net: nps_enet: Fix module autoload
Date: Mon, 17 Oct 2016 11:05:40 -0300
Message-ID: <1476713146-26632-2-git-send-email-javier@osg.samsung.com>
References: <1476713146-26632-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Lada Trimasova <Lada.Trimasova@synopsys.com>,
        Noam Camus <noamca@mellanox.com>,
        Elad Kanfi <eladkan@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Gilad Ben-Yossef <giladby@mellanox.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:35521
        "EHLO s-opensource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934495AbcJQOGK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 10:06:10 -0400
In-Reply-To: <1476713146-26632-1-git-send-email-javier@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the driver is built as a module, autoload won't work because the module
alias information is not filled. So user-space can't match the registered
device with the corresponding module.

Export the module alias information using the MODULE_DEVICE_TABLE() macro.

Before this patch:

$ modinfo drivers/net/ethernet/ezchip/nps_enet.ko | grep alias
$

After this patch:

$ modinfo drivers/net/ethernet/ezchip/nps_enet.ko | grep alias
alias:          of:N*T*Cezchip,nps-mgt-enetC*
alias:          of:N*T*Cezchip,nps-mgt-enet

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/ethernet/ezchip/nps_enet.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index f928e6f79c89..223f35cc034c 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -669,6 +669,7 @@ static const struct of_device_id nps_enet_dt_ids[] = {
 	{ .compatible = "ezchip,nps-mgt-enet" },
 	{ /* Sentinel */ }
 };
+MODULE_DEVICE_TABLE(of, nps_enet_dt_ids);
 
 static struct platform_driver nps_enet_driver = {
 	.probe = nps_enet_probe,
-- 
2.7.4
