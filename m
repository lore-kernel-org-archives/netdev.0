From: Joe Perches <joe@perches.com>
Subject: [PATCH] ipv6.h: reassembly: replace calculated magic number with
 multiplication
Date: Tue, 16 Feb 2010 20:40:04 -0800
Message-ID: <1266381604.8446.17.camel@Joe-Laptop.home>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
	 <20100216145545.2796.47717.sendpatchset@x2.localnet>
	 <1266335018.29987.50.camel@Joe-Laptop.home>  <4B7ABDF8.8010004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shan Wei <shanwei@cn.fujitsu.com>, davem@davemloft.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B7ABDF8.8010004@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-02-16 at 16:47 +0100, Patrick McHardy wrote:
> Joe Perches wrote:
> >> @@ -246,6 +246,8 @@ extern int ipv6_opt_accepted(struct sock *sk, struct sk_buff *skb);
> >>  int ip6_frag_nqueues(struct net *net);
> >>  int ip6_frag_mem(struct net *net);
> >>  
> >> +#define IPV6_FRAG_HIGH_THRESH	262144		/* == 256*1024 */
> >> +#define IPV6_FRAG_LOW_THRESH	196608		/* == 192*1024 */
> >>  #define IPV6_FRAG_TIMEOUT	(60*HZ)		/* 60 seconds */
> > 
> > 196608 isn't a number I want to remember.
> > Is this better as:
> > 
> > #define IPV6_FRAG_HIGH_THRESH	(256 * 1024)	/* 262144 */
> > #define IPV6_FRAG_LOW_THRESH	(192 * 1024)	/* 196608 */
> 
> Please send a patch, I'll apply it once these patches are in Dave's
> tree.

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 639ec53..d067db1 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -246,9 +246,9 @@ extern int ipv6_opt_accepted(struct sock *sk, struct sk_buff *skb);
 int ip6_frag_nqueues(struct net *net);
 int ip6_frag_mem(struct net *net);
 
-#define IPV6_FRAG_HIGH_THRESH	262144		/* == 256*1024 */
-#define IPV6_FRAG_LOW_THRESH	196608		/* == 192*1024 */
-#define IPV6_FRAG_TIMEOUT	(60*HZ)		/* 60 seconds */
+#define IPV6_FRAG_HIGH_THRESH	(256 * 1024)	/* 262144 */
+#define IPV6_FRAG_LOW_THRESH	(192 * 1024)	/* 196608 */
+#define IPV6_FRAG_TIMEOUT	(60 * HZ)	/* 60 seconds */
 
 extern int __ipv6_addr_type(const struct in6_addr *addr);
 static inline int ipv6_addr_type(const struct in6_addr *addr)




