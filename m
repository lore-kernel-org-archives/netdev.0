From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] ipv6: fix incorrect bitwise operator used on rt6i_flags
Date: Tue, 10 Oct 2017 19:10:30 +0100
Message-ID: <20171010181030.22290-1-colin.king@canonical.com>
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

The use of the | operator always leads to true which looks rather
suspect to me. Fix this by using & instead to just check the
RTF_CACHE entry bit.

Detected by CoverityScan, CID#1457734, #1457747 ("Wrong operator used")

Fixes: 35732d01fe31 ("ipv6: introduce a hash table to store dst cache")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/ipv6/route.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 6db1541eaa7b..dd9ba1192dbc 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1425,7 +1425,7 @@ int rt6_remove_exception_rt(struct rt6_info *rt)
 	int err;
 
 	if (!from ||
-	    !(rt->rt6i_flags | RTF_CACHE))
+	    !(rt->rt6i_flags & RTF_CACHE))
 		return -EINVAL;
 
 	if (!rcu_access_pointer(from->rt6i_exception_bucket))
@@ -1469,7 +1469,7 @@ static void rt6_update_exception_stamp_rt(struct rt6_info *rt)
 	struct rt6_exception *rt6_ex;
 
 	if (!from ||
-	    !(rt->rt6i_flags | RTF_CACHE))
+	    !(rt->rt6i_flags & RTF_CACHE))
 		return;
 
 	rcu_read_lock();
-- 
2.14.1
