From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [TEMPORARY] net: netfilter: IPV6 XT sockets need CONFIG_NF_DEFRAG_IPV6
Date: Thu, 29 Jan 2015 17:18:59 +0100
Message-ID: <1513018.IdvuSAziQY@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, KOVACS Krisztian <hidden@sch.bme.hu>,
	linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:49707 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869AbbA2QT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 11:19:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If IP6_NF_IPTABLES=m, NF_DEFRAG_IPV6 gets selected as a module as well
from NETFILTER_XT_MATCH_SOCKET, so the latter cannot be built-in, or
we get:

net/built-in.o: In function `socket_mt_init':
:(.init.text+0x32a0): undefined reference to `nf_defrag_ipv6_enable'
net/built-in.o: In function `tproxy_tg_init':
xt_TPROXY.c:582: undefined reference to `nf_defrag_ipv6_enable'

This adds one more dependency like the others to avoid the problem.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index b02660fa9eb0..2bd57d62a385 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -875,6 +875,7 @@ config NETFILTER_XT_TARGET_TPROXY
 	depends on NETFILTER_ADVANCED
 	depends on (IPV6 || IPV6=n)
 	depends on IP_NF_MANGLE
+	depends on (IP6_NF_IPTABLES || !IP6_NF_IPTABLES)
 	select NF_DEFRAG_IPV4
 	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
 	help
@@ -1367,6 +1368,7 @@ config NETFILTER_XT_MATCH_SOCKET
 	depends on NETFILTER_ADVANCED
 	depends on !NF_CONNTRACK || NF_CONNTRACK
 	depends on (IPV6 || IPV6=n)
+	depends on (IP6_NF_IPTABLES || !IP6_NF_IPTABLES)
 	select NF_DEFRAG_IPV4
 	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
 	help
