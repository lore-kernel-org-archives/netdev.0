From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH] macvtap: remove wrong sock_put() in macvtap_put_queue()
Date: Mon, 13 Jun 2011 11:15:19 +0800
Message-ID: <1307934919-4189-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, arnd@arndb.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30595 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753790Ab1FMDOP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jun 2011 23:14:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The calling of sock_put() should be delayed after synchronize_rcu(),
otherwise inconsist data may be seen during packets transmitting.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 6696e56..ecdb775 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -148,7 +148,6 @@ static void macvtap_put_queue(struct macvtap_queue *q)
 
 		rcu_assign_pointer(vlan->taps[index], NULL);
 		rcu_assign_pointer(q->vlan, NULL);
-		sock_put(&q->sk);
 		--vlan->numvtaps;
 	}
 
-- 
1.7.1

