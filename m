From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] net: cpsw: catch of_get_phy_mode failing and propagate error
Date: Wed, 12 Feb 2014 23:33:22 +0100
Message-ID: <1392244402-24823-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel@pengutronix.de, Mugunthan V N <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44279 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753066AbaBLWdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:33:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's wrong if the device tree doesn't provide a phy-mode property for
the cpsw slaves as it is documented to be required in
Documentation/devicetree/bindings/net/cpsw.txt.

Anyhow it's nice to catch that problem, still more as it used to work
without this property up to commit 388367a5a9fb (drivers: net: cpsw: us=
e
cpsw-phy-sel driver to configure phy mode) which is in v3.13-rc1.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/c=
psw.c
index 1d860ce914ed..542c5114851c 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1896,6 +1896,11 @@ static int cpsw_probe_dt(struct cpsw_platform_da=
ta *data,
 			memcpy(slave_data->mac_addr, mac_addr, ETH_ALEN);
=20
 		slave_data->phy_if =3D of_get_phy_mode(slave_node);
+		if (slave_data->phy_if < 0) {
+			pr_err("Missing or malformed slave[%d] phy-mode property\n",
+			       i);
+			return slave_data->phy_if;
+		}
=20
 		if (data->dual_emac) {
 			if (of_property_read_u32(slave_node, "dual_emac_res_vlan",
--=20
1.8.5.3
