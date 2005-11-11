From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 01/10]: [NETFILTER]: Remove okfn usage in ip_vs_core.c
Date: Fri, 11 Nov 2005 04:19:14 +0100
Message-ID: <43740DB2.20804@trash.net>
Mime-Version: 1.0
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline;
 filename="01.diff"
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

okfn should only be used from different contexts to avoid deep
call stacks, i.e. by nf_queue.

Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit e718fcad3d24ada7b56fdca8dd234c9ba7459219
tree 0f067bbacbeb03439707940a1ad7b504c8251187
parent 0bbacc402e67abca8794a8401c1621dc0c0202e9
author Patrick McHardy <kaber@trash.net> Fri, 11 Nov 2005 02:09:52 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 11 Nov 2005 02:09:52 +0100

 net/ipv4/ipvs/ip_vs_core.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 981cc32..7b13722 100644
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
