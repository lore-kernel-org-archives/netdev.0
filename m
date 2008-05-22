From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 2/2] NETFRONT: Use __skb_queue_purge()
Date: Thu, 22 May 2008 18:09:06 +0800
Message-ID: <48354642.2090508@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51519 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1759260AbYEVKLl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:11:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use standard routine for queue purging.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/xen-netfront.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 8bddff1..d26f69b 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -946,8 +946,7 @@ err:
 		work_done++;
 	}
 
-	while ((skb = __skb_dequeue(&errq)))
-		kfree_skb(skb);
+	__skb_queue_purge(&errq);
 
 	work_done -= handle_incoming_queue(dev, &rxq);
 
@@ -1079,8 +1078,7 @@ static void xennet_release_rx_bufs(struct netfront_info *np)
 		}
 	}
 
-	while ((skb = __skb_dequeue(&free_list)) != NULL)
-		dev_kfree_skb(skb);
+	__skb_queue_purge(&free_list);
 
 	spin_unlock_bh(&np->rx_lock);
 }
-- 
1.5.4.rc3

