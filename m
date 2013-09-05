From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for Sep 5 (netfilter: xt_socket.c)
Date: Thu, 05 Sep 2013 14:38:30 -0400 (EDT)
Message-ID: <20130905.143830.660252697193033003.davem@davemloft.net>
References: <20130905193249.8b7c57afd5e39349ff5508bb@canb.auug.org.au>
	<5228C140.1010504@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: rdunlap@infradead.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <5228C140.1010504@infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>
Date: Thu, 05 Sep 2013 10:37:04 -0700

> On 09/05/13 02:32, Stephen Rothwell wrote:
>> Hi all,
>> 
>> Please do not add any code for v3.13 to your linux-next included branches
>> until after v3.12-rc1 is released.
>> 
>> Changes since 20130904:
>> 
> 
> on x86_64:
> 
> when CONFIG_IPV6=m
> and CONFIG_NETFILTER_XT_MATCH_SOCKET=y:
> 
> net/built-in.o: In function `socket_mt6_v1_v2':
> xt_socket.c:(.text+0x51b55): undefined reference to `udp6_lib_lookup'
> net/built-in.o: In function `socket_mt_init':
> xt_socket.c:(.init.text+0x1ef8): undefined reference to `nf_defrag_ipv6_enable'

I just commited the following to fix this:

--------------------
[PATCH] netfilter: Fix build errors with xt_socket.c

As reported by Randy Dunlap:

====================
when CONFIG_IPV6=m
and CONFIG_NETFILTER_XT_MATCH_SOCKET=y:

net/built-in.o: In function `socket_mt6_v1_v2':
xt_socket.c:(.text+0x51b55): undefined reference to `udp6_lib_lookup'
net/built-in.o: In function `socket_mt_init':
xt_socket.c:(.init.text+0x1ef8): undefined reference to `nf_defrag_ipv6_enable'
====================

Like several other modules under net/netfilter/ we have to
have a dependency "IPV6 disabled or set compatibly with this
module" clause.

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 62a171a..6e839b6 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -1175,6 +1175,7 @@ config NETFILTER_XT_MATCH_SOCKET
 	depends on NETFILTER_XTABLES
 	depends on NETFILTER_ADVANCED
 	depends on !NF_CONNTRACK || NF_CONNTRACK
+	depends on (IPV6 || IPV6=n)
 	select NF_DEFRAG_IPV4
 	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
 	help
-- 
1.7.11.7

