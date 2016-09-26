From: "Albert ARIBAUD (3ADEV)" <albert.aribaud@3adev.fr>
Subject: [PATCH] net: trivial: fix fsl fec_main mdio write return value
Date: Mon, 26 Sep 2016 21:11:40 +0200
Message-ID: <20160926191140.12107-1-albert.aribaud@3adev.fr>
Cc: Jiri Kosina <trivial@kernel.org>, Fugang Duan <fugang.duan@nxp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:63466 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965069AbcIZTLu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Sep 2016 15:11:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the MDIO enf-of-transfer wait loop does not time out,
0 should be returned to the caller through ret, but ret
was not reset to 0 after receiving the return value of
pm_runtime_get_sync(). Reset ret when no time out occurred.

Signed-off-by: Albert ARIBAUD (3ADEV) <albert.aribaud@3adev.fr>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 01f7e81..0413c05 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1818,6 +1818,8 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 		netdev_err(fep->netdev, "MDIO write timeout\n");
 		ret  = -ETIMEDOUT;
 	}
+	else
+		ret = 0;
 
 	pm_runtime_mark_last_busy(dev);
 	pm_runtime_put_autosuspend(dev);
-- 
2.9.3
