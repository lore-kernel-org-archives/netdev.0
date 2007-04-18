From: Erik Hovland <erik@hovland.org>
Subject: [PATCH] Make dev_kfree_skb_any check if the skb is valid
Date: Wed, 18 Apr 2007 15:33:44 -0700
Message-ID: <20070418223339.GE13146@hovland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trivial@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:56297 "EHLO
	mail6.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753568AbXDRWk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 18:40:26 -0400
Received: from dsl092-045-201.lax1.dsl.speakeasy.net (HELO speakeasy.net) ([66.92.45.201])
          (envelope-sender <erik@hovland.org>)
          by mail6.sea5.speakeasy.net (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 18 Apr 2007 22:33:46 -0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If dev_kfree_skb_any is called and it then calls dev_kfree_skb_irq.
That call will dereference the skb. If the skb is invalid, down the
drain we go.

This one-liner checks to see if the skb is valid as part of the
determination of whether to call dev_kfree_skb_irq.

Signed-off-by: Erik Hovland <erik@hovland.org>

---

 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 4dc93cc..85f4a4c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1131,7 +1131,7 @@ EXPORT_SYMBOL(__netif_rx_schedule);
 
 void dev_kfree_skb_any(struct sk_buff *skb)
 {
-	if (in_irq() || irqs_disabled())
+	if (skb && (in_irq() || irqs_disabled()))
 		dev_kfree_skb_irq(skb);
 	else
 		dev_kfree_skb(skb);

