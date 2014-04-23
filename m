From: Richard Guy Briggs <rgb@redhat.com>
Subject: [PATCH 1/6][v2] netlink: simplify nfnetlink_bind
Date: Tue, 22 Apr 2014 21:31:53 -0400
Message-ID: <8ae3bd558cb6619428cc40e467d1643f9d382a0a.1398215388.git.rgb@redhat.com>
References: <20140422.161904.1187535812839850973.davem@davemloft.net>
Cc: Richard Guy Briggs <rgb@redhat.com>, davem@davemloft.net,
	jamal@mojatatu.com, eparis@redhat.com, sgrubb@redhat.com
To: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140422.161904.1187535812839850973.davem@davemloft.net>
In-Reply-To: <cover.1398215388.git.rgb@redhat.com>
References: <cover.1398215388.git.rgb@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove duplicity and simplify code flow by moving the rcu_read_unlock() above
the condition and let the flow control exit naturally at the end of the
function.

Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
---
 net/netfilter/nfnetlink.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index e8138da..0df800a 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -407,12 +407,9 @@ static void nfnetlink_bind(int group)
 
 	rcu_read_lock();
 	ss = nfnetlink_get_subsys(type);
-	if (!ss) {
-		rcu_read_unlock();
-		request_module("nfnetlink-subsys-%d", type);
-		return;
-	}
 	rcu_read_unlock();
+	if (!ss)
+		request_module("nfnetlink-subsys-%d", type);
 }
 #endif
 
-- 
1.7.1
