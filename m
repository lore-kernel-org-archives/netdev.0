From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH] net: Use kmemdup rather than duplicating its implementation
Date: Thu, 17 Nov 2011 23:43:40 +0100
Message-ID: <1321569820.1624.307.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: samuel@sortiz.org, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The semantic patch that makes this change is available
in scripts/coccinelle/api/memdup.cocci.

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/net/irda/irttp.c b/net/irda/irttp.c
--- a/net/irda/irttp.c 2011-11-07 19:39:06.071138486 +0100
+++ b/net/irda/irttp.c 2011-11-08 10:59:07.152748948 +0100
@@ -1461,14 +1461,13 @@ struct tsap_cb *irttp_dup(struct tsap_cb
 	}
 
 	/* Allocate a new instance */
-	new = kmalloc(sizeof(struct tsap_cb), GFP_ATOMIC);
+	new = kmemdup(orig, sizeof(struct tsap_cb), GFP_ATOMIC);
 	if (!new) {
 		IRDA_DEBUG(0, "%s(), unable to kmalloc\n", __func__);
 		spin_unlock_irqrestore(&irttp->tsaps->hb_spinlock, flags);
 		return NULL;
 	}
 	/* Dup */
-	memcpy(new, orig, sizeof(struct tsap_cb));
 	spin_lock_init(&new->lock);
 
 	/* We don't need the old instance any more */
