From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/4] netfilter: avoid build error if TPROXY/SOCKET=y && NF_DEFRAG_IPV6=m
Date: Sat, 16 May 2015 20:47:16 +0200
Message-ID: <1431802038-4502-3-git-send-email-pablo@netfilter.org>
References: <1431802038-4502-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42827 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751818AbbEPSmj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 May 2015 14:42:39 -0400
In-Reply-To: <1431802038-4502-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

With TPROXY=y but DEFRAG_IPV6=m we get build failure:

net/built-in.o: In function `tproxy_tg_init':
net/netfilter/xt_TPROXY.c:588: undefined reference to `nf_defrag_ipv6_enable'

If DEFRAG_IPV6 is modular, TPROXY must be too.
(or both must be builtin).

This enforces =m for both.

Reported-and-tested-by: Liu Hua <liusdu@126.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index f70e34a..a0f3e6a3 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -863,6 +863,7 @@ config NETFILTER_XT_TARGET_TPROXY
 	depends on NETFILTER_XTABLES
 	depends on NETFILTER_ADVANCED
 	depends on (IPV6 || IPV6=n)
+	depends on (IP6_NF_IPTABLES || IP6_NF_IPTABLES=n)
 	depends on IP_NF_MANGLE
 	select NF_DEFRAG_IPV4
 	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
@@ -1356,6 +1357,7 @@ config NETFILTER_XT_MATCH_SOCKET
 	depends on NETFILTER_ADVANCED
 	depends on !NF_CONNTRACK || NF_CONNTRACK
 	depends on (IPV6 || IPV6=n)
+	depends on (IP6_NF_IPTABLES || IP6_NF_IPTABLES=n)
 	select NF_DEFRAG_IPV4
 	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
 	help
-- 
1.7.10.4
