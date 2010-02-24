From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Subject: [PATCH] greth: convert to netdev_tx_t
Date: Wed, 24 Feb 2010 23:25:33 +0300
Message-ID: <20100224202533.GA4531@coldcone>
Reply-To: kirjanov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: kristoffer@gaisler.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f219.google.com ([209.85.220.219]:38647 "EHLO
	mail-fx0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757814Ab0BXUXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 15:23:39 -0500
Received: by fxm19 with SMTP id 19so5509717fxm.21
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2010 12:23:38 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to netdev_tx_t
Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>
---
 drivers/net/greth.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index d203233..d75b461 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -66,8 +66,10 @@ module_param(greth_edcl, int, 0);
 MODULE_PARM_DESC(greth_edcl, "GRETH EDCL usage indicator. Set to 1 if EDCL is used.");
 
 static int greth_open(struct net_device *dev);
-static int greth_start_xmit(struct sk_buff *skb, struct net_device *dev);
-static int greth_start_xmit_gbit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t greth_start_xmit(struct sk_buff *skb,
+	   struct net_device *dev);
+static netdev_tx_t greth_start_xmit_gbit(struct sk_buff *skb,
+	   struct net_device *dev);
 static int greth_rx(struct net_device *dev, int limit);
 static int greth_rx_gbit(struct net_device *dev, int limit);
 static void greth_clean_tx(struct net_device *dev);
@@ -379,7 +381,8 @@ static int greth_close(struct net_device *dev)
 	return 0;
 }
 
-static int greth_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t
+greth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct greth_private *greth = netdev_priv(dev);
 	struct greth_bd *bdp;
@@ -441,7 +444,8 @@ out:
 }
 
 
-static int greth_start_xmit_gbit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t
+greth_start_xmit_gbit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct greth_private *greth = netdev_priv(dev);
 	struct greth_bd *bdp;
