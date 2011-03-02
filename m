From: kaber@trash.net
Subject: [PATCH 07/13] ipvs: fix timer in get_curr_sync_buff
Date: Wed,  2 Mar 2011 13:12:47 +0100
Message-ID: <1299067973-15977-8-git-send-email-kaber@trash.net>
References: <1299067973-15977-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1299067973-15977-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tinggong Wang <wangtinggong@gmail.com>

 	Fix get_curr_sync_buff to keep buffer for 2 seconds
as intended, not just for the current jiffie. By this way
we will sync more connection structures with single packet.

Signed-off-by: Tinggong Wang <wangtinggong@gmail.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index d1b7298..fecf24d 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -374,8 +374,8 @@ get_curr_sync_buff(struct netns_ipvs *ipvs, unsigned long time)
 	struct ip_vs_sync_buff *sb;
 
 	spin_lock_bh(&ipvs->sync_buff_lock);
-	if (ipvs->sync_buff && (time == 0 ||
-	    time_before(jiffies - ipvs->sync_buff->firstuse, time))) {
+	if (ipvs->sync_buff &&
+	    time_after_eq(jiffies - ipvs->sync_buff->firstuse, time)) {
 		sb = ipvs->sync_buff;
 		ipvs->sync_buff = NULL;
 	} else
-- 
1.7.4

