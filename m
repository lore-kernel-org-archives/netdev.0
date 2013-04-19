From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/5] netfilter: xt_rpfilter: depend on raw or mangle table
Date: Fri, 19 Apr 2013 03:23:57 +0200
Message-ID: <1366334638-5113-6-git-send-email-pablo@netfilter.org>
References: <1366334638-5113-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57218 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967757Ab3DSBYW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 21:24:22 -0400
In-Reply-To: <1366334638-5113-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

rpfilter is only valid in raw/mangle PREROUTING, i.e.
RPFILTER=y|m is useless without raw or mangle table support.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/Kconfig |    2 +-
 net/ipv6/netfilter/Kconfig |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 0d755c5..e7916c1 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -71,7 +71,7 @@ config IP_NF_MATCH_ECN
 
 config IP_NF_MATCH_RPFILTER
 	tristate '"rpfilter" reverse path filter match support'
-	depends on NETFILTER_ADVANCED
+	depends on NETFILTER_ADVANCED && (IP_NF_MANGLE || IP_NF_RAW)
 	---help---
 	  This option allows you to match packets whose replies would
 	  go out via the interface the packet came in.
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index c72532a..4433ab40 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -105,7 +105,7 @@ config IP6_NF_MATCH_MH
 
 config IP6_NF_MATCH_RPFILTER
 	tristate '"rpfilter" reverse path filter match support'
-	depends on NETFILTER_ADVANCED
+	depends on NETFILTER_ADVANCED && (IP6_NF_MANGLE || IP6_NF_RAW)
 	---help---
 	  This option allows you to match packets whose replies would
 	  go out via the interface the packet came in.
-- 
1.7.10.4
