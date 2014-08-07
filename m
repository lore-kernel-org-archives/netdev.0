From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 2/3] net: ucc_geth: make probe consistently acquire a reference to the phy node
Date: Thu,  7 Aug 2014 23:48:25 +0200
Message-ID: <1407448106-1819-2-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1407448106-1819-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, Florian Fainelli <f.fainelli@gmail.com>
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58436 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755333AbaHGVsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 17:48:51 -0400
In-Reply-To: <1407448106-1819-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the driver attaches to a device that has a phy handle the probe
routine returns with a reference to that node. This reference is
correctly dropped in the error path and the remove function. In the
fixed phy case however no reference is acquired and so the error path
might drop a reference the driver isn't holding. Fix that by getting a
reference to the MAC.

=46ixes: 87009814cdbb ("ucc_geth: use the new fixed PHY helpers")
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/ethernet/freescale/ucc_geth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/et=
hernet/freescale/ucc_geth.c
index 5f1aab9c4ee7..a22ff770f9e5 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3796,7 +3796,7 @@ static int ucc_geth_probe(struct platform_device*=
 ofdev)
 			if (err)
 				return err;
 		}
-		ug_info->phy_node =3D np;
+		ug_info->phy_node =3D of_node_get(np);
 	}
=20
 	/* Find the TBI PHY node.  If it's not there, we don't support SGMII =
*/
--=20
2.0.1
