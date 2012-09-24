From: pablo@netfilter.org
Subject: [PATCH 01/16] netfilter: fix IPv6 NAT dependencies in Kconfig
Date: Mon, 24 Sep 2012 21:19:13 +0200
Message-ID: <1348514369-3272-2-git-send-email-pablo@netfilter.org>
References: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

* NF_NAT_IPV6 requires IP6_NF_IPTABLES

* IP6_NF_TARGET_MASQUERADE, IP6_NF_TARGET_NETMAP, IP6_NF_TARGET_REDIRECT
  and IP6_NF_TARGET_NPT require NF_NAT_IPV6.

This change just mirrors what IPv4 does in Kconfig, for consistency.

Reported-by: Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/Kconfig |  110 ++++++++++++++++++++++----------------------
 1 file changed, 55 insertions(+), 55 deletions(-)

diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 3b73254..d8f276b 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -25,18 +25,6 @@ config NF_CONNTRACK_IPV6
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
-config NF_NAT_IPV6
-	tristate "IPv6 NAT"
-	depends on NF_CONNTRACK_IPV6
-	depends on NETFILTER_ADVANCED
-	select NF_NAT
-	help
-	  The IPv6 NAT option allows masquerading, port forwarding and other
-	  forms of full Network Address Port Translation. It is controlled by
-	  the `nat' table in ip6tables, see the man page for ip6tables(8).
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP6_NF_IPTABLES
 	tristate "IP6 tables support (required for filtering)"
 	depends on INET && IPV6
@@ -144,48 +132,6 @@ config IP6_NF_TARGET_HL
 	(e.g. when running oldconfig). It selects
 	CONFIG_NETFILTER_XT_TARGET_HL.
 
-config IP6_NF_TARGET_MASQUERADE
-	tristate "MASQUERADE target support"
-	depends on NF_NAT_IPV6
-	help
-	  Masquerading is a special case of NAT: all outgoing connections are
-	  changed to seem to come from a particular interface's address, and
-	  if the interface goes down, those connections are lost.  This is
-	  only useful for dialup accounts with dynamic IP address (ie. your IP
-	  address will be different on next dialup).
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
-config IP6_NF_TARGET_NETMAP
-	tristate "NETMAP target support"
-	depends on NF_NAT_IPV6
-	help
-	  NETMAP is an implementation of static 1:1 NAT mapping of network
-	  addresses. It maps the network address part, while keeping the host
-	  address part intact.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
-config IP6_NF_TARGET_REDIRECT
-	tristate "REDIRECT target support"
-	depends on NF_NAT_IPV6
-	help
-	  REDIRECT is a special case of NAT: all incoming connections are
-	  mapped onto the incoming interface's address, causing the packets to
-	  come to the local machine instead of passing through.  This is
-	  useful for transparent proxies.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
-config IP6_NF_TARGET_NPT
-	tristate "NPT (Network Prefix translation) target support"
-	depends on NETFILTER_ADVANCED
-	help
-	  This option adds the `SNPT' and `DNPT' target, which perform
-	  stateless IPv6-to-IPv6 Network Prefix Translation per RFC 6296.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config IP6_NF_FILTER
 	tristate "Packet filtering"
 	default m if NETFILTER_ADVANCED=n
@@ -235,9 +181,63 @@ config IP6_NF_SECURITY
        help
          This option adds a `security' table to iptables, for use
          with Mandatory Access Control (MAC) policy.
-        
+
          If unsure, say N.
 
+config NF_NAT_IPV6
+	tristate "IPv6 NAT"
+	depends on NF_CONNTRACK_IPV6
+	depends on NETFILTER_ADVANCED
+	select NF_NAT
+	help
+	  The IPv6 NAT option allows masquerading, port forwarding and other
+	  forms of full Network Address Port Translation. It is controlled by
+	  the `nat' table in ip6tables, see the man page for ip6tables(8).
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+if NF_NAT_IPV6
+
+config IP6_NF_TARGET_MASQUERADE
+	tristate "MASQUERADE target support"
+	help
+	  Masquerading is a special case of NAT: all outgoing connections are
+	  changed to seem to come from a particular interface's address, and
+	  if the interface goes down, those connections are lost.  This is
+	  only useful for dialup accounts with dynamic IP address (ie. your IP
+	  address will be different on next dialup).
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+config IP6_NF_TARGET_NETMAP
+	tristate "NETMAP target support"
+	help
+	  NETMAP is an implementation of static 1:1 NAT mapping of network
+	  addresses. It maps the network address part, while keeping the host
+	  address part intact.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+config IP6_NF_TARGET_REDIRECT
+	tristate "REDIRECT target support"
+	help
+	  REDIRECT is a special case of NAT: all incoming connections are
+	  mapped onto the incoming interface's address, causing the packets to
+	  come to the local machine instead of passing through.  This is
+	  useful for transparent proxies.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+config IP6_NF_TARGET_NPT
+	tristate "NPT (Network Prefix translation) target support"
+	help
+	  This option adds the `SNPT' and `DNPT' target, which perform
+	  stateless IPv6-to-IPv6 Network Prefix Translation per RFC 6296.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+endif # NF_NAT_IPV6
+
 endif # IP6_NF_IPTABLES
 
 endmenu
-- 
1.7.10.4

