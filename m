From: Hans de Goede <hdegoede@redhat.com>
Subject: [PATCH 1/2] net: stmmac: Silence PTP init errors on hw without PTP
Date: Sun, 26 Jan 2014 15:50:43 +0100
Message-ID: <1390747844-25060-1-git-send-email-hdegoede@redhat.com>
Cc: netdev@vger.kernel.org, Hans de Goede <hdegoede@redhat.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44450 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751444AbaAZOuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Jan 2014 09:50:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Logging a PTP error on hw which simply does not support PTP is not very
useful. Moreover this message gets logged on every if-up, and if there is
no cable inserted NetworkManager will re-try the ifup every 50 seconds.

Signed-off-by: Hans de Goede <hdegoede@redhat.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index ff514b5..838d0b7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1687,7 +1687,7 @@ static int stmmac_open(struct net_device *dev)
 	stmmac_mmc_setup(priv);
 
 	ret = stmmac_init_ptp(priv);
-	if (ret)
+	if (ret && ret != -EOPNOTSUPP)
 		pr_warn("%s: failed PTP initialisation\n", __func__);
 
 #ifdef CONFIG_STMMAC_DEBUG_FS
-- 
1.8.5.3
