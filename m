From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH v2 net-next 7/7] mac802154: add monitor listener to TX datapath
Date: Tue, 26 Jun 2012 13:24:54 +0400
Message-ID: <1340702694-24706-8-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1340702694-24706-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:32808 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617Ab2FZJ3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 05:29:12 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so5026860wgb.1
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 02:29:11 -0700 (PDT)
In-Reply-To: <1340702694-24706-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add monitor receive callback to the TX datapath to catch all the
data sent to transceivers.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/mac802154/tx.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
index 434b687..1a4df39 100644
--- a/net/mac802154/tx.c
+++ b/net/mac802154/tx.c
@@ -88,6 +88,8 @@ netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
+	mac802154_monitors_rx(mac802154_to_priv(&priv->hw), skb);
+
 	if (!(priv->hw.flags & IEEE802154_HW_OMIT_CKSUM)) {
 		u16 crc = crc_ccitt(0, skb->data, skb->len);
 		u8 *data = skb_put(skb, 2);
-- 
1.7.2.3
