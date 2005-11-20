From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 01/13]: [NETFILTER]: Remove okfn usage in ip_vs_core.c
Date: Sun, 20 Nov 2005 17:31:29 +0100
Message-ID: <20051120163129.16666.54743.sendpatchset@localhost.localdomain>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: davem@davemloft.net
In-Reply-To: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

[NETFILTER]: Remove okfn usage in ip_vs_core.c

okfn should only be used from different contexts to avoid deep call stacks,
i.e. by nf_queue.

Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit ebb0baec0a5e909d4acf16a15601f013093fefb3
tree da877af1ad83666e8ccd54dd94da485444e6b37b
parent b286e39207237e2f6929959372bf66d9a8d05a82
author Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 21:48:33 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 21:48:33 +0100

 net/ipv4/ipvs/ip_vs_core.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 1a0843c..b63bb28 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -532,11 +532,8 @@ static unsigned int ip_vs_post_routing(u
 {
 	if (!((*pskb)->ipvs_property))
 		return NF_ACCEPT;
-
 	/* The packet was sent from IPVS, exit this chain */
-	(*okfn)(*pskb);
-
-	return NF_STOLEN;
+	return NF_STOP;
 }
 
 u16 ip_vs_checksum_complete(struct sk_buff *skb, int offset)
