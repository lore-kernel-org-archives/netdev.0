From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 5/13] [IPV6] Make IPV6_SUBTREES depend on IPV6_MULTIPLE_TABLES.
Date: Tue, 17 Oct 2006 03:08:35 +0300
Message-ID: <45341F03.7050209@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:61969 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1422964AbWJQAIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 20:08:37 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


As IPV6_SUBTREES can't work without IPV6_MULTIPLE_TABLES have IPV6_SUBTREES
depend on it.

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 net/ipv6/Kconfig |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index a2d211d..5fd2ffd 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -152,9 +152,16 @@ config IPV6_TUNNEL

 	  If unsure, say N.

+config IPV6_MULTIPLE_TABLES
+	bool "IPv6: Multiple Routing Tables"
+	depends on IPV6 && EXPERIMENTAL
+	select FIB_RULES
+	---help---
+	  Support multiple routing tables.
+
 config IPV6_SUBTREES
 	bool "IPv6: source address based routing"
-	depends on IPV6 && EXPERIMENTAL
+	depends on IPV6_MULTIPLE_TABLES
 	---help---
 	  Enable routing by source address or prefix.

@@ -166,13 +173,6 @@ config IPV6_SUBTREES

 	  If unsure, say N.

-config IPV6_MULTIPLE_TABLES
-	bool "IPv6: Multiple Routing Tables"
-	depends on IPV6 && EXPERIMENTAL
-	select FIB_RULES
-	---help---
-	  Support multiple routing tables.
-
 config IPV6_ROUTE_FWMARK
 	bool "IPv6: use netfilter MARK value as routing key"
 	depends on IPV6_MULTIPLE_TABLES && NETFILTER
-- 
1.4.2.3

