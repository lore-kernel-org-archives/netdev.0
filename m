From: Richard Guy Briggs <rgb@redhat.com>
Subject: [PATCH 1/3] netlink: simplify nfnetlink_bind
Date: Tue,  1 Apr 2014 10:14:56 -0400
Message-ID: <b182ddbee24a1bb1d339b966de4cbc5a2b9c96b0.1396317747.git.rgb@redhat.com>
References: <20140324183406.GE28666@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Richard Guy Briggs <rgb@redhat.com>, davem@davemloft.net,
        hadi@mojatatu.com
To: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <20140324183406.GE28666@madcap2.tricolour.ca>
In-Reply-To: <cover.1396317747.git.rgb@redhat.com>
References: <cover.1396317747.git.rgb@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

Remove duplicity and simplify code flow by moving the rcu_read_unlock() above
the condition and let the flow control exit naturally at the end of the
function.

Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
---
 net/netfilter/nfnetlink.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 046aa13..1da5ef1 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -399,12 +399,9 @@ static void nfnetlink_bind(int group)
 
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
