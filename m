From: Ross Lagerwall <ross.lagerwall@citrix.com>
Subject: [PATCH 4.4-only] netlink: Allow direct reclaim for fallback allocation
Date: Fri, 21 Apr 2017 09:52:54 +0100
Message-ID: <1492764774-22199-1-git-send-email-ross.lagerwall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Anoob Soman <anoob.soman@citrix.com>,
        Ross Lagerwall <ross.lagerwall@citrix.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The backport of d35c99ff77ec ("netlink: do not enter direct reclaim from
netlink_dump()") to the 4.4 branch (first in 4.4.32) mistakenly removed
direct claim from the initial large allocation and the fallback
allocation which means that allocations can spuriously fail.
Fix the issue by adding back the direct reclaim flag to the fallback
allocation.

Fixes: 6d123f1d396b ("netlink: do not enter direct reclaim from netlink_dump()")
Signed-off-by: Ross Lagerwall <ross.lagerwall@citrix.com>
---
 net/netlink/af_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 8e33019..acfb16f 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2107,7 +2107,7 @@ static int netlink_dump(struct sock *sk)
 	if (!skb) {
 		alloc_size = alloc_min_size;
 		skb = netlink_alloc_skb(sk, alloc_size, nlk->portid,
-					(GFP_KERNEL & ~__GFP_DIRECT_RECLAIM));
+					GFP_KERNEL);
 	}
 	if (!skb)
 		goto errout_skb;
-- 
2.7.4
