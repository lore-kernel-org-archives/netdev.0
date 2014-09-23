From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/5] netfilter: xt_TPROXY: undefined reference to `udp6_lib_lookup'
Date: Tue, 23 Sep 2014 11:24:48 +0200
Message-ID: <1411464288-18069-6-git-send-email-pablo@netfilter.org>
References: <1411464288-18069-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53483 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754446AbaIWJXw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 05:23:52 -0400
In-Reply-To: <1411464288-18069-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_IPV6=m
CONFIG_NETFILTER_XT_TARGET_TPROXY=y

   net/built-in.o: In function `nf_tproxy_get_sock_v6.constprop.11':
>> xt_TPROXY.c:(.text+0x583a1): undefined reference to `udp6_lib_lookup'
   net/built-in.o: In function `tproxy_tg_init':
>> xt_TPROXY.c:(.init.text+0x1dc3): undefined reference to `nf_defrag_ipv6_enable'

This fix is similar to 1a5bbfc ("netfilter: Fix build errors with
xt_socket.c").

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 4bef6eb..831f960 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -839,6 +839,7 @@ config NETFILTER_XT_TARGET_TPROXY
 	tristate '"TPROXY" target transparent proxying support'
 	depends on NETFILTER_XTABLES
 	depends on NETFILTER_ADVANCED
+	depends on (IPV6 || IPV6=n)
 	depends on IP_NF_MANGLE
 	select NF_DEFRAG_IPV4
 	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
-- 
1.7.10.4
