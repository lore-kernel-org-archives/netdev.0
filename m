From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v3 03/13] net: ethernet: ti: cpsw: remove priv from cpsw_get_slave_port() parameters list
Date: Wed, 10 Aug 2016 02:22:34 +0300
Message-ID: <1470784964-26440-4-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlide@ti.com, Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37916 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932558AbcHIXX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 19:23:28 -0400
Received: by mail-wm0-f46.google.com with SMTP id o80so66906545wme.1
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 16:23:27 -0700 (PDT)
In-Reply-To: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need in priv here.

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>
Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 21cf367..4f6a4c1 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -525,7 +525,7 @@ static const struct cpsw_stats cpsw_gstrings_stats[] = {
 		if (priv->data.dual_emac) {				\
 			struct cpsw_slave *slave = priv->slaves +	\
 						priv->emac_port;	\
-			int slave_port = cpsw_get_slave_port(priv,	\
+			int slave_port = cpsw_get_slave_port(		\
 						slave->slave_num);	\
 			cpsw_ale_add_mcast(priv->ale, addr,		\
 				1 << slave_port | ALE_PORT_HOST,	\
@@ -537,7 +537,7 @@ static const struct cpsw_stats cpsw_gstrings_stats[] = {
 		}							\
 	} while (0)
 
-static inline int cpsw_get_slave_port(struct cpsw_priv *priv, u32 slave_num)
+static inline int cpsw_get_slave_port(u32 slave_num)
 {
 	return slave_num + 1;
 }
@@ -847,7 +847,7 @@ static void _cpsw_adjust_link(struct cpsw_slave *slave,
 	if (!phy)
 		return;
 
-	slave_port = cpsw_get_slave_port(priv, slave->slave_num);
+	slave_port = cpsw_get_slave_port(slave->slave_num);
 
 	if (phy->link) {
 		mac_control = priv->data.mac_control;
@@ -1118,7 +1118,7 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 
 	slave->mac_control = 0;	/* no link yet */
 
-	slave_port = cpsw_get_slave_port(priv, slave->slave_num);
+	slave_port = cpsw_get_slave_port(slave->slave_num);
 
 	if (priv->data.dual_emac)
 		cpsw_add_dual_emac_def_ale_entries(priv, slave, slave_port);
@@ -1220,7 +1220,7 @@ static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_priv *priv)
 {
 	u32 slave_port;
 
-	slave_port = cpsw_get_slave_port(priv, slave->slave_num);
+	slave_port = cpsw_get_slave_port(slave->slave_num);
 
 	if (!slave->phy)
 		return;
-- 
1.9.1
