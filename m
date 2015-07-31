From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net] stmmac: fix missing MODULE_LICENSE in stmmac_platform
Date: Fri, 31 Jul 2015 19:02:32 +0200
Message-ID: <1438362152-11865-1-git-send-email-manabian@gmail.com>
References: <CAFMg4WCm6rs6xMKPiKGmALc45+ne-xUzQgYHH7zOPotQ-iEqjg@mail.gmail.com>
Cc: netdev@vger.kernel.org, maxime.ripard@anandra.org,
	Joachim Eastwood <manabian@gmail.com>
To: peppe.cavallaro@st.com, davem@davemloft.net,
	i.gnatenko.brain@gmail.co
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:33293 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753813AbbGaRDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 13:03:00 -0400
Received: by lbbyj8 with SMTP id yj8so49875848lbb.0
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 10:02:58 -0700 (PDT)
In-Reply-To: <CAFMg4WCm6rs6xMKPiKGmALc45+ne-xUzQgYHH7zOPotQ-iEqjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 50649ab14982 ("stmmac: drop driver from stmmac platform code")
was a bit overzealous in removing code and dropped the MODULE_*
macro's that are still needed since stmmac_platform can be a module.
Fix this by putting the macro's remvoed in 50649ab14982 back.

This fixes the following errors when used as a module:
  stmmac_platform: module license 'unspecified' taints kernel.
  Disabling lock debugging due to kernel taint
  stmmac_platform: Unknown symbol devm_kmalloc (err 0)
  stmmac_platform: Unknown symbol stmmac_suspend (err 0)
  stmmac_platform: Unknown symbol platform_get_irq_byname (err 0)
  stmmac_platform: Unknown symbol stmmac_dvr_remove (err 0)
  stmmac_platform: Unknown symbol platform_get_resource (err 0)
  stmmac_platform: Unknown symbol of_get_phy_mode (err 0)
  stmmac_platform: Unknown symbol of_property_read_u32_array (err 0)
  stmmac_platform: Unknown symbol of_alias_get_id (err 0)
  stmmac_platform: Unknown symbol stmmac_resume (err 0)
  stmmac_platform: Unknown symbol stmmac_dvr_probe (err 0)

Fixes: 50649ab14982 ("stmmac: drop driver from stmmac platform code")
Reported-by: Igor Gnatenko <i.gnatenko.brain@gmail.com>
Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
Hi,

An alternative solution could be to change CONFIG_STMMAC_PLATFORM
into a bool, but I guess we want to keep things as modular as
possible.

Please test this Igor and report back. Thanks!

 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index f3918c7e7eeb..bcdc8955c719 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -413,3 +413,7 @@ static int stmmac_pltfr_resume(struct device *dev)
 SIMPLE_DEV_PM_OPS(stmmac_pltfr_pm_ops, stmmac_pltfr_suspend,
 				       stmmac_pltfr_resume);
 EXPORT_SYMBOL_GPL(stmmac_pltfr_pm_ops);
+
+MODULE_DESCRIPTION("STMMAC 10/100/1000 Ethernet platform support");
+MODULE_AUTHOR("Giuseppe Cavallaro <peppe.cavallaro@st.com>");
+MODULE_LICENSE("GPL");
-- 
1.8.0
