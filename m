From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH] net/mac80211: Use RCU_INIT_POINTER(x, NULL) in debugfs.c
Date: Mon, 24 Mar 2014 00:45:59 +0530
Message-ID: <1395602159-13427-1-git-send-email-monamagarwal123@gmail.com>
To: linville@tuxdriver.com, johannes@sipsolutions.net,
	davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)

The rcu_assign_pointer() ensures that the initialization of a structure       
is carried out before storing a pointer to that structure. 
And in the case of the NULL pointer, there is no structure to initialize. 
So, rcu_assign_pointer(p, NULL) can be safely converted to RCU_INIT_POINTER(p, NULL)

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 net/mac80211/debugfs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac80211/debugfs.c b/net/mac80211/debugfs.c
index fa16e54..0e963bc 100644
--- a/net/mac80211/debugfs.c
+++ b/net/mac80211/debugfs.c
@@ -128,7 +128,7 @@ static ssize_t sta_tx_latency_stat_write(struct file *file,
 	if (!strcmp(buf, TX_LATENCY_DISABLED)) {
 		if (!tx_latency)
 			goto unlock;
-		rcu_assign_pointer(local->tx_latency, NULL);
+		RCU_INIT_POINTER(local->tx_latency, NULL);
 		synchronize_rcu();
 		kfree(tx_latency);
 		goto unlock;
-- 
1.7.9.5
