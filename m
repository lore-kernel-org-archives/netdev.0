From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] net: ucc_geth: fix build failure
Date: Sun, 10 Aug 2014 20:32:05 +0200
Message-ID: <1407695525-32227-1-git-send-email-u.kleine-koenig@pengutronix.de>
References: <20140808.135237.120203200807493642.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Li Yang <leoli@freescale.com>, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, kernel@pengutronix.de,
	Florian Fainelli <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:39685 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022AbaHJScS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2014 14:32:18 -0400
In-Reply-To: <20140808.135237.120203200807493642.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My series to fix the reference counting of dt nodes introduced a build
failure. Fix it.

=46ixes: fa310789a488 ("net: ucc_geth: drop acquired references in prob=
e error path and remove")
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
Hello,

I found a powerpc toolchain now, so this really builds now. Sorry for t=
he
inconvenience.

Uwe

 drivers/net/ethernet/freescale/ucc_geth.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/et=
hernet/freescale/ucc_geth.c
index d6b64e316527..3cf0478b3728 100644
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
2.0.1
