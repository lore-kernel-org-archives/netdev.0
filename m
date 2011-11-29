From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] batman-adv: remove extra negation in gw_out_of_range()
Date: Tue, 29 Nov 2011 09:09:09 +0300
Message-ID: <20111129060909.GA6098@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	"David S. Miller" <davem@davemloft.net>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Marek Lindner <lindner_marek@yahoo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:54080 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809Ab1K2GJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 01:09:44 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a typo here where an extra '!' made the check to the opposite
of what was intended.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 9373a14..24403a7 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -695,7 +695,7 @@ bool gw_out_of_range(struct bat_priv *bat_priv,
 	}
 
 	neigh_old = find_router(bat_priv, orig_dst_node, NULL);
-	if (!!neigh_old)
+	if (!neigh_old)
 		goto out;
 
 	if (curr_tq_avg - neigh_old->tq_avg > GW_THRESHOLD)
