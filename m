From: Vasily Averin <vvs@parallels.com>
Subject: [PATCH] ipv4: "conntrack zones" support for defrag user check in
 ip_expire
Date: Sat, 03 May 2014 03:14:04 +0400
Message-ID: <536426BC.7020509@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Defrag user check in ip_expire was not updated after adding support for
"conntrack zones"

Signed-off-by: Vasily Averin <vvs@openvz.org>
---
 net/ipv4/ip_fragment.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index c10a3ce..ed32313 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -232,8 +232,9 @@ static void ip_expire(unsigned long arg)
 		 * "Fragment Reassembly Timeout" message, per RFC792.
 		 */
 		if (qp->user == IP_DEFRAG_AF_PACKET ||
-		    (qp->user == IP_DEFRAG_CONNTRACK_IN &&
-		     skb_rtable(head)->rt_type != RTN_LOCAL))
+		    ((qp->user >= IP_DEFRAG_CONNTRACK_IN) &&
+		     (qp->user <= __IP_DEFRAG_CONNTRACK_IN_END) &&
+		     (skb_rtable(head)->rt_type != RTN_LOCAL)))
 			goto out_rcu_unlock;
 
 
-- 
1.7.5.4

