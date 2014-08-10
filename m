From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] net: ugg_geth: Fix build error in -next
Date: Sun, 10 Aug 2014 09:19:14 -0700
Message-ID: <1407687554-14539-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>,
	=?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:44385 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbaHJQTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2014 12:19:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

powerpc:mpc83xx_defconfig and other builds fail with

drivers/net/ethernet/freescale/ucc_geth.c: In function 'ucc_geth_remove=
':
drivers/net/ethernet/freescale/ucc_geth.c:3927:19: error:
	'struct ucc_geth_private' has no member named 'info'
  of_node_put(ugeth->info->tbi_node);
                     ^
drivers/net/ethernet/freescale/ucc_geth.c:3928:19: error:
	     'struct ucc_geth_private' has no member named 'info'
  of_node_put(ugeth->info->phy_node);
  		     ^

Introduced by commit "net: ucc_geth: drop acquired references in probe =
error
path and remove".

=46rom the context, it appears that the variable is named ug_info.

Cc: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
Only seen in -next.

 drivers/net/ethernet/freescale/ucc_geth.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/et=
hernet/freescale/ucc_geth.c
index d6b64e3..3cf0478 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3924,8 +3924,8 @@ static int ucc_geth_remove(struct platform_device=
* ofdev)
 	unregister_netdev(dev);
 	free_netdev(dev);
 	ucc_geth_memclean(ugeth);
-	of_node_put(ugeth->info->tbi_node);
-	of_node_put(ugeth->info->phy_node);
+	of_node_put(ugeth->ug_info->tbi_node);
+	of_node_put(ugeth->ug_info->phy_node);
=20
 	return 0;
 }
--=20
1.9.1
