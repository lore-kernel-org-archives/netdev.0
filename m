From: Jakub Kicinski <moorray3@wp.pl>
Subject: [PATCH 2/3] gianfar: correct list membership accounting
Date: Mon, 10 Aug 2015 22:12:19 +0200
Message-ID: <1439237540-11302-3-git-send-email-moorray3@wp.pl>
References: <1439237540-11302-1-git-send-email-moorray3@wp.pl>
Cc: netdev@vger.kernel.org, Jakub Kicinski <kubakici@wp.pl>
To: "David S. Miller" <davem@davemloft.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:7026 "EHLO mx3.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752498AbbHJUMa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2015 16:12:30 -0400
In-Reply-To: <1439237540-11302-1-git-send-email-moorray3@wp.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <kubakici@wp.pl>

At a cost of one line let's make sure .count is correct
when calling gfar_process_filer_changes().

Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
---
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index e543d3b01838..b955ed83ca98 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -1723,13 +1723,14 @@ static int gfar_add_cls(struct gfar_private *priv,
 	}
 
 process:
+	priv->rx_list.count++;
 	ret = gfar_process_filer_changes(priv);
 	if (ret)
 		goto clean_list;
-	priv->rx_list.count++;
 	return ret;
 
 clean_list:
+	priv->rx_list.count--;
 	list_del(&temp->list);
 clean_mem:
 	kfree(temp);
-- 
2.1.0
