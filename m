From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 7/7] net: dsa: bcm_sf2: Fix module autoload for OF registration
Date: Mon, 17 Oct 2016 11:05:46 -0300
Message-ID: <1476713146-26632-8-git-send-email-javier@osg.samsung.com>
References: <1476713146-26632-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:35564
        "EHLO s-opensource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934881AbcJQOG2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 10:06:28 -0400
In-Reply-To: <1476713146-26632-1-git-send-email-javier@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the driver is built as a module, autoload won't work because the module
alias information is not filled. So user-space can't match the registered
device with the corresponding module.

Export the module alias information using the MODULE_DEVICE_TABLE() macro.

Before this patch:

$ modinfo drivers/net/dsa/bcm_sf2.ko | grep alias
alias:          platform:brcm-sf2

After this patch:

$ modinfo drivers/net/dsa/bcm_sf2.ko | grep alias
alias:          platform:brcm-sf2
alias:          of:N*T*Cbrcm,bcm7445-switch-v4.0C*
alias:          of:N*T*Cbrcm,bcm7445-switch-v4.0

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

---

 drivers/net/dsa/bcm_sf2.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index e218887f18b7..0427009bc924 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1158,6 +1158,7 @@ static const struct of_device_id bcm_sf2_of_match[] = {
 	{ .compatible = "brcm,bcm7445-switch-v4.0" },
 	{ /* sentinel */ },
 };
+MODULE_DEVICE_TABLE(of, bcm_sf2_of_match);
 
 static struct platform_driver bcm_sf2_driver = {
 	.probe	= bcm_sf2_sw_probe,
-- 
2.7.4
