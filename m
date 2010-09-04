From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 1/1] NET: bna, fix lock imbalance
Date: Sat,  4 Sep 2010 14:08:41 +0200
Message-ID: <1283602121-11443-1-git-send-email-jslaby@suse.cz>
Cc: linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	netdev@vger.kernel.org, Debashis Dutt <ddutt@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bnad_set_rx_mode omit to unlock bna_lock on one fail path. Fix that.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Debashis Dutt <ddutt@brocade.com>
Cc: Rasesh Mody <rmody@brocade.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/bna/bnad.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index cbc1d56..a1a449a 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -2706,7 +2706,7 @@ bnad_set_rx_mode(struct net_device *netdev)
 			kzalloc((mc_count + 1) * ETH_ALEN,
 				GFP_ATOMIC);
 		if (!mcaddr_list)
-			return;
+			goto unlock;
 
 		memcpy(&mcaddr_list[0], &bnad_bcast_addr[0], ETH_ALEN);
 
@@ -2719,6 +2719,7 @@ bnad_set_rx_mode(struct net_device *netdev)
 		/* Should we enable BNAD_CF_ALLMULTI for err != 0 ? */
 		kfree(mcaddr_list);
 	}
+unlock:
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 }
 
-- 
1.7.2.2
