From: Jakub Kicinski <moorray3@wp.pl>
Subject: [PATCH 1/3] gianfar: correct filer table writing
Date: Mon, 10 Aug 2015 22:12:18 +0200
Message-ID: <1439237540-11302-2-git-send-email-moorray3@wp.pl>
References: <1439237540-11302-1-git-send-email-moorray3@wp.pl>
Cc: netdev@vger.kernel.org, Jakub Kicinski <kubakici@wp.pl>
To: "David S. Miller" <davem@davemloft.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:6057 "EHLO mx3.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932448AbbHJUTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2015 16:19:09 -0400
In-Reply-To: <1439237540-11302-1-git-send-email-moorray3@wp.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <kubakici@wp.pl>

MAX_FILER_IDX is the last usable index.  Using less-than
will already guarantee that one entry for catch-all rule
will be left, no need to subtract 1 here.

Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
---
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 555e461b0cfe..e543d3b01838 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -1585,11 +1585,10 @@ static int gfar_write_filer_table(struct gfar_private *priv,
 		return -EBUSY;
 
 	/* Fill regular entries */
-	for (; i < MAX_FILER_IDX - 1 && (tab->fe[i].ctrl | tab->fe[i].prop);
-	     i++)
+	for (; i < MAX_FILER_IDX && (tab->fe[i].ctrl | tab->fe[i].prop); i++)
 		gfar_write_filer(priv, i, tab->fe[i].ctrl, tab->fe[i].prop);
 	/* Fill the rest with fall-troughs */
-	for (; i < MAX_FILER_IDX - 1; i++)
+	for (; i < MAX_FILER_IDX; i++)
 		gfar_write_filer(priv, i, 0x60, 0xFFFFFFFF);
 	/* Last entry must be default accept
 	 * because that's what people expect
-- 
2.1.0
