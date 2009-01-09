From: akpm@linux-foundation.org
Subject: [patch 3/4] drivers/net/wireless/libertas: move a dereference below a NULL test
Date: Fri, 09 Jan 2009 12:23:10 -0800
Message-ID: <200901092023.n09KNAL5020198@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, julia@diku.dk,
	dcbw@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38318 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751916AbZAIUfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 15:35:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

In each case, if the NULL test is necessary, then the dereference should be
moved below the NULL test.  I have also taken advantage of the availability
of the value of priv->dev in the subsequent calls to netif_stop_queue and
netif_carrier_off.

The semantic patch that makes this change is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
type T;
expression E;
identifier i,fld;
statement S;
@@

- T i = E->fld;
+ T i;
  ... when != E
      when != i
  if (E == NULL) S
+ i = E->fld;
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
Acked-by: Dan Williams <dcbw@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/wireless/libertas/main.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff -puN drivers/net/wireless/libertas/main.c~drivers-net-wireless-libertas-move-a-dereference-below-a-null-test drivers/net/wireless/libertas/main.c
--- a/drivers/net/wireless/libertas/main.c~drivers-net-wireless-libertas-move-a-dereference-below-a-null-test
+++ a/drivers/net/wireless/libertas/main.c
@@ -1369,7 +1369,7 @@ EXPORT_SYMBOL_GPL(lbs_start_card);
 
 void lbs_stop_card(struct lbs_private *priv)
 {
-	struct net_device *dev = priv->dev;
+	struct net_device *dev;
 	struct cmd_ctrl_node *cmdnode;
 	unsigned long flags;
 
@@ -1377,9 +1377,10 @@ void lbs_stop_card(struct lbs_private *p
 
 	if (!priv)
 		goto out;
+	dev = priv->dev;
 
-	netif_stop_queue(priv->dev);
-	netif_carrier_off(priv->dev);
+	netif_stop_queue(dev);
+	netif_carrier_off(dev);
 
 	lbs_debugfs_remove_one(priv);
 	if (priv->mesh_tlv) {
_
