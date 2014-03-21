From: Richard Guy Briggs <rgb@redhat.com>
Subject: [PATCH] netlink: simplify nfnetlink_bind
Date: Fri, 21 Mar 2014 12:44:09 -0400
Message-ID: <d9a410952c6b88e5855d36f91c06d466d2ce9bed.1395418617.git.rgb@redhat.com>
Cc: Richard Guy Briggs <rgb@redhat.com>, eparis@redhat.com,
	sgrubb@redhat.com, hadi@mojatatu.com, davem@davemloft.net
To: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove duplicity and simplify code flow by moving the rcu_read_unlock() above
the condition and let the flow control exit naturally at the end of the
function.

Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
---
 net/netfilter/nfnetlink.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 046aa13..75619f9 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -399,12 +399,10 @@ static void nfnetlink_bind(int group)
 
 	rcu_read_lock();
 	ss = nfnetlink_get_subsys(type);
+	rcu_read_unlock();
 	if (!ss) {
-		rcu_read_unlock();
 		request_module("nfnetlink-subsys-%d", type);
-		return;
 	}
-	rcu_read_unlock();
 }
 #endif
 
-- 
1.7.1

