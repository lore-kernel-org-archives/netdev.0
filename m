From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net] gianfar: Fix overflow check and return value for
 gfar_get_cls_all()
Date: Tue, 06 Sep 2011 23:44:25 +0100
Message-ID: <1315349065.2788.18.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Sebastian Poehn <sebastian.poehn@belden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:38785 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753378Ab1IFWo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 18:44:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function may currently fill one entry beyond the end of the
array it is given.  It also doesn't return an error code in case
it does detect overflow.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This code is new for 3.1, so no stable update required.

Not tested in any way, as this driver depends on FSL_SOC.

Ben.

 drivers/net/gianfar_ethtool.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 25a8c2a..0caf3c3 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -1669,10 +1669,10 @@ static int gfar_get_cls_all(struct gfar_private *priv,
 	u32 i = 0;
 
 	list_for_each_entry(comp, &priv->rx_list.list, list) {
-		if (i <= cmd->rule_cnt) {
-			rule_locs[i] = comp->fs.location;
-			i++;
-		}
+		if (i == cmd->rule_cnt)
+			return -EMSGSIZE;
+		rule_locs[i] = comp->fs.location;
+		i++;
 	}
 
 	cmd->data = MAX_FILER_IDX;
-- 
1.7.4.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
