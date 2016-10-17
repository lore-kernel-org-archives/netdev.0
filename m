From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 6/7] net: dsa: b53: Fix module autoload
Date: Mon, 17 Oct 2016 11:05:45 -0300
Message-ID: <1476713146-26632-7-git-send-email-javier@osg.samsung.com>
References: <1476713146-26632-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476713146-26632-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the driver is built as a module, autoload won't work because the module
alias information is not filled. So user-space can't match the registered
device with the corresponding module.

Export the module alias information using the MODULE_DEVICE_TABLE() macro.

Before this patch:

$ modinfo drivers/net/dsa/b53/b53_mmap.ko  | grep alias
$

After this patch:

$ modinfo drivers/net/dsa/b53/b53_mmap.ko  | grep alias
alias:          of:N*T*Cbrcm,bcm63xx-switchC*
alias:          of:N*T*Cbrcm,bcm63xx-switch
alias:          of:N*T*Cbrcm,bcm6368-switchC*
alias:          of:N*T*Cbrcm,bcm6368-switch
alias:          of:N*T*Cbrcm,bcm6328-switchC*
alias:          of:N*T*Cbrcm,bcm6328-switch
alias:          of:N*T*Cbrcm,bcm3384-switchC*
alias:          of:N*T*Cbrcm,bcm3384-switch

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/dsa/b53/b53_mmap.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dsa/b53/b53_mmap.c b/drivers/net/dsa/b53/b53_mmap.c
index 76fb8552c9d9..ef63d24fef81 100644
--- a/drivers/net/dsa/b53/b53_mmap.c
+++ b/drivers/net/dsa/b53/b53_mmap.c
@@ -256,6 +256,7 @@ static const struct of_device_id b53_mmap_of_table[] = {
 	{ .compatible = "brcm,bcm63xx-switch" },
 	{ /* sentinel */ },
 };
+MODULE_DEVICE_TABLE(of, b53_mmap_of_table);
 
 static struct platform_driver b53_mmap_driver = {
 	.probe = b53_mmap_probe,
-- 
2.7.4
