From: Alan Ott <alan@signal11.us>
Subject: [PATCH] mac802154: Keep track of the channel when changed
Date: Fri,  5 Apr 2013 16:36:41 -0400
Message-ID: <1365194201-2635-1-git-send-email-alan@signal11.us>
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Alan Ott <alan@signal11.us>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:41922 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1162032Ab3DEUg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 16:36:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prevent set_channel() from getting called every time a packet is sent. This
looks like it was an oversight.

Signed-off-by: Alan Ott <alan@signal11.us>
---
 net/mac802154/tx.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
index 3fd3e07..6d16473 100644
--- a/net/mac802154/tx.c
+++ b/net/mac802154/tx.c
@@ -58,6 +58,9 @@ static void mac802154_xmit_worker(struct work_struct *work)
 			pr_debug("set_channel failed\n");
 			goto out;
 		}
+
+		xw->priv->phy->current_channel = xw->chan;
+		xw->priv->phy->current_page = xw->page;
 	}
 
 	res = xw->priv->ops->xmit(&xw->priv->hw, xw->skb);
-- 
1.7.11.2
