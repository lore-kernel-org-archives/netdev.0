From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: core: rtnetlink: use BUG_ON instead of if condition
 followed by BUG
Date: Fri, 20 Oct 2017 19:43:11 -0500
Message-ID: <20171021004311.GA25170@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use BUG_ON instead of if condition followed by BUG in do_setlink.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only.

 net/core/rtnetlink.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 04680a5..df8dba9 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2274,8 +2274,7 @@ static int do_setlink(const struct sk_buff *skb,
 
 			rcu_read_lock();
 
-			if (!(af_ops = rtnl_af_lookup(nla_type(af))))
-				BUG();
+			BUG_ON(!(af_ops = rtnl_af_lookup(nla_type(af))));
 
 			err = af_ops->set_link_af(dev, af);
 			if (err < 0) {
-- 
2.7.4
