From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] libertas: fix an error code in probe
Date: Tue, 8 Mar 2016 15:04:08 +0300
Message-ID: <20160308120408.GA28684@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Kemnade <andreas@kemnade.info>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35704 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753856AbcCHMF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 07:05:56 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We accidentally return success instead of a negative error code.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/wireless/marvell/libertas/main.c b/drivers/net/wireless/marvell/libertas/main.c
index b35b8bc..8541cbe 100644
--- a/drivers/net/wireless/marvell/libertas/main.c
+++ b/drivers/net/wireless/marvell/libertas/main.c
@@ -1118,7 +1118,8 @@ int lbs_start_card(struct lbs_private *priv)
 	else
 		pr_info("%s: mesh disabled\n", dev->name);
 
-	if (lbs_cfg_register(priv)) {
+	ret = lbs_cfg_register(priv);
+	if (ret) {
 		pr_err("cannot register device\n");
 		goto done;
 	}
