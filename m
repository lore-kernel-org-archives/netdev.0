From: Eduardo Habkost <ehabkost@redhat.com>
Subject: [PATCH][resend] xen-netfront: use netif_start_queue() on xennet_open()
Date: Thu, 31 Jul 2008 17:36:55 -0300
Message-ID: <1217536615-2090-1-git-send-email-ehabkost@redhat.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Eduardo Habkost <ehabkost@redhat.com>
To: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52963 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752293AbYGaUij (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2008 16:38:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xen-netfront never called netif_start_queue() and was was waking the
queue on xennet_open(), triggering the BUG_ON() on __netif_schedule().

Signed-off-by: Eduardo Habkost <ehabkost@redhat.com>
---
 drivers/net/xen-netfront.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 902bbe7..c749bdb 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -329,7 +329,7 @@ static int xennet_open(struct net_device *dev)
 	}
 	spin_unlock_bh(&np->rx_lock);
 
-	xennet_maybe_wake_tx(dev);
+	netif_start_queue(dev);
 
 	return 0;
 }
-- 
1.5.5.GIT

