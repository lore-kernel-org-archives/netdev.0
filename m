From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next] ipv6: fix dereference of rt6_ex before null check error
Date: Tue, 10 Oct 2017 18:01:16 +0100
Message-ID: <20171010170116.21124-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Currently rt6_ex is being dereferenced before it is null checked
hence there is a possible null dereference bug. Fix this by only
dereferencing rt6_ex after it has been null checked.

Detected by CoverityScan, CID#1457749 ("Dereference before null check")

Fixes: 81eb8447daae ("ipv6: take care of rt6_stats")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/ipv6/route.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 606e80325b21..6db1541eaa7b 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1152,10 +1152,12 @@ static DEFINE_SPINLOCK(rt6_exception_lock);
 static void rt6_remove_exception(struct rt6_exception_bucket *bucket,
 				 struct rt6_exception *rt6_ex)
 {
-	struct net *net = dev_net(rt6_ex->rt6i->dst.dev);
+	struct net *net;
 
 	if (!bucket || !rt6_ex)
 		return;
+
+	net = dev_net(rt6_ex->rt6i->dst.dev);
 	rt6_ex->rt6i->rt6i_node = NULL;
 	hlist_del_rcu(&rt6_ex->hlist);
 	rt6_release(rt6_ex->rt6i);
-- 
2.14.1
