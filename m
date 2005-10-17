From: Patrick McHardy <kaber@trash.net>
Subject: [NF+IPsec 1/6]: Remove okfn usage in ip_vs_core.c
Date: Mon, 17 Oct 2005 02:22:03 +0200
Message-ID: <4352EEAB.8030708@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000305040907030102020606"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
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

This is a multi-part message in MIME format.
--------------000305040907030102020606
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This is my current set of netfilter+IPsec patches with Herbert's
suggestions incorporated. Changes since the last posted patches:

- remove okfn use in ipvs and ip_conntrack to avoid deep
   callchains with IPsec
- only pass packets to netfilter after tunnel mode transforms,
   except for once in plain before encapsulation or after
   decapsulation.
- NAT support

--------------000305040907030102020606
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[NETFILTER]: Remove okfn usage in ip_vs_core.c

okfn should only be used from different contexts, i.e. by nf_queue.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 12a6be7122de1d1039298adc6f401b3edf8788e5
tree dff6bfdcfc17dd7eb497bfdcb40214086bcc815c
parent 7a3ca7d2b5ec31b2cfa594b961d77e68075e33c7
author Patrick McHardy <kaber@trash.net> Sun, 16 Oct 2005 16:11:23 +0200
committer Patrick McHardy <kaber@trash.net> Sun, 16 Oct 2005 16:11:23 +0200

 net/ipv4/ipvs/ip_vs_core.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
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

--------------000305040907030102020606--
