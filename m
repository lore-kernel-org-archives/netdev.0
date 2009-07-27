From: Thomas Gleixner <tglx@linutronix.de>
Subject: [PATCH] net: irda: init spinlock after memcpy
Date: Mon, 27 Jul 2009 14:12:24 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.0907271407590.2936@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:60850 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751028AbZG0MMf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 08:12:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deepak Saxena <dsaxena@mvista.com>

irttp_dup() copies a tsap_cb struct, but does not initialize the
spinlock in the new structure, which confuses lockdep.

Signed-off-by: Deepak Saxena <dsaxena@mvista.com>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index ecf4eb2..9cb79f9 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -1453,6 +1453,7 @@ struct tsap_cb *irttp_dup(struct tsap_cb *orig, void *instance)
 	}
 	/* Dup */
 	memcpy(new, orig, sizeof(struct tsap_cb));
+	spin_lock_init(&new->lock);
 
 	/* We don't need the old instance any more */
 	spin_unlock_irqrestore(&irttp->tsaps->hb_spinlock, flags);
