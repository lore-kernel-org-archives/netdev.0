From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for June 23 (net)
Date: Thu, 23 Jun 2011 21:21:20 -0700 (PDT)
Message-ID: <20110623.212120.2043173528294538748.davem@davemloft.net>
References: <20110623155431.6bfe3b40.sfr@canb.auug.org.au>
	<20110623091429.2d51b0f0.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110623091429.2d51b0f0.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 23 Jun 2011 09:14:29 -0700

> On Thu, 23 Jun 2011 15:54:31 +1000 Stephen Rothwell wrote:
> 
>> Hi all,
>> 
>> Changes since 20110622:
>> 
>> The powerpc allyesconfig (and probably others) is still broken because we
>> now build the staging drivers and because of a commit in the net tree.
>> The breakage in Linus' tree is fixed by one of Andrew's patches above.
>> 
>> The net tree gained 2 build failures that I have left (see above).
> 
> 
> When CONFIG_INET is not enabled:
> 
> net/core/dev.c:2535: error: implicit declaration of function 'ip_is_fragment'

I'll fix this like so:

diff --git a/include/net/ip.h b/include/net/ip.h
index d603cd3..9fa9416 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -236,6 +236,11 @@ extern void ipfrag_init(void);
 
 extern void ip_static_sysctl_init(void);
 
+static inline bool ip_is_fragment(const struct iphdr *iph)
+{
+	return (iph->frag_off & htons(IP_MF | IP_OFFSET)) != 0;
+}
+
 #ifdef CONFIG_INET
 #include <net/dst.h>
 
@@ -250,11 +255,6 @@ int ip_decrease_ttl(struct iphdr *iph)
 	return --iph->ttl;
 }
 
-static inline bool ip_is_fragment(const struct iphdr *iph)
-{
-	return (iph->frag_off & htons(IP_MF | IP_OFFSET)) != 0;
-}
-
 static inline
 int ip_dont_fragment(struct sock *sk, struct dst_entry *dst)
 {
