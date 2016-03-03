From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 4/4] tipc: make sure required
	IPv6 addresses are scoped
Date: Thu, 3 Mar 2016 14:20:43 +0100
Message-ID: <1457011243-23605-4-git-send-email-richard.alpe@ericsson.com>
References: <1457011243-23605-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1457011243-23605-1-git-send-email-richard.alpe@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Make sure the user has provided a scope for multicast and link local
addresses used locally by a UDP bearer.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@gmail.com>
---
 net/tipc/udp_media.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index 6fe8740..fb2f7ec6 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -310,9 +310,14 @@ err:
 
 #if IS_ENABLED(CONFIG_IPV6)
 	} else if ((sa_local.ss_family & sa_remote.ss_family) == AF_INET6) {
+		int atype;
 		struct sockaddr_in6 *ip6;
 
 		ip6 = (struct sockaddr_in6 *)&sa_local;
+		atype = ipv6_addr_type(&ip6->sin6_addr);
+		if (__ipv6_addr_needs_scope_id(atype) && !ip6->sin6_scope_id)
+			return -EINVAL;
+
 		local->proto = htons(ETH_P_IPV6);
 		local->udp_port = ip6->sin6_port;
 		memcpy(&local->ipv6, &ip6->sin6_addr, sizeof(struct in6_addr));
-- 
2.1.4


------------------------------------------------------------------------------
Site24x7 APM Insight: Get Deep Visibility into Application Performance
APM + Mobile APM + RUM: Monitor 3 App instances at just $35/Month
Monitor end-to-end web transactions and take corrective actions now
Troubleshoot faster and improve end-user experience. Signup Now!
http://pubads.g.doubleclick.net/gampad/clk?id=272487151&iu=/4140
