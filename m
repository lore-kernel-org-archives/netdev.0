From: Al Boldi <a1426z@gawab.com>
Subject: [PATCH][v2] Netfilter Kconfig: Expose IPv4/6 connection tracking
	options by selecting NF_CONNTRACK_ENABLED
Date: Wed, 25 Jul 2007 18:02:22 +0300
Message-ID: <200707251802.22200.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, Sam Ravnborg <sam@ravnborg.org>,
	Patrick McHardy <kaber@trash.net>, David Miller <davem@davemloft.net>
To: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
Content-Disposition: inline
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


Make NF_CONNTRACK_IPV4 and NF_CONNTRACK_IPV6 select NF_CONNTRACK_ENABLED.

This exposes IPv4/6 connection tracking options for easier Kconfig setup.

Signed-off-by: Al Boldi <a1426z@gawab.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: David Miller <davem@davemloft.net>
Cc: Sam Ravnborg <sam@ravnborg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
--- a/net/netfilter/Kconfig	2007-07-09 06:38:52.000000000 +0300
+++ b/net/netfilter/Kconfig	2007-07-25 17:37:16.000000000 +0300
@@ -28,6 +28,7 @@ config NETFILTER_NETLINK_LOG
 # Rename this to NF_CONNTRACK in a 2.6.25
 config NF_CONNTRACK_ENABLED
 	tristate "Netfilter connection tracking support"
+	select NF_CONNTRACK
 	help
 	  Connection tracking keeps a record of what packets have passed
 	  through your machine, in order to figure out how they are related
--- a/net/ipv4/netfilter/Kconfig	2007-07-09 06:38:50.000000000 +0300
+++ b/net/ipv4/netfilter/Kconfig	2007-07-25 17:37:39.000000000 +0300
@@ -7,7 +7,7 @@ menu "IP: Netfilter Configuration"
 
 config NF_CONNTRACK_IPV4
 	tristate "IPv4 connection tracking support (required for NAT)"
-	depends on NF_CONNTRACK
+	select NF_CONNTRACK_ENABLED
 	---help---
 	  Connection tracking keeps a record of what packets have passed
 	  through your machine, in order to figure out how they are related
--- a/net/ipv6/netfilter/Kconfig	2007-07-09 06:38:51.000000000 +0300
+++ b/net/ipv6/netfilter/Kconfig	2007-07-25 17:37:57.000000000 +0300
@@ -7,7 +7,8 @@ menu "IPv6: Netfilter Configuration (EXP
 
 config NF_CONNTRACK_IPV6
 	tristate "IPv6 connection tracking support (EXPERIMENTAL)"
-	depends on INET && IPV6 && EXPERIMENTAL && NF_CONNTRACK
+	depends on INET && IPV6 && EXPERIMENTAL
+	select NF_CONNTRACK_ENABLED
 	---help---
 	  Connection tracking keeps a record of what packets have passed
 	  through your machine, in order to figure out how they are related
