From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/17] netfilter: fix unmet dependencies in NETFILTER_XT_TARGET_REDIRECT
Date: Mon, 24 Nov 2014 14:27:47 +0100
Message-ID: <1416835674-11871-11-git-send-email-pablo@netfilter.org>
References: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44891 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932094AbaKXNZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2014 08:25:57 -0500
In-Reply-To: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

warning: (NETFILTER_XT_TARGET_REDIRECT) selects NF_NAT_REDIRECT_IPV4 which has unmet direct dependencies (NET && INET && NETFILTER && NF_NAT_IPV4)

warning: (NETFILTER_XT_TARGET_REDIRECT) selects NF_NAT_REDIRECT_IPV6 which has unmet direct dependencies (NET && INET && IPV6 && NETFILTER && NF_NAT_IPV6)

Fixes: 8b13edd ("netfilter: refactor NAT redirect IPv4 to use it from nf_tables")
Fixes: 9de920e ("netfilter: refactor NAT redirect IPv6 code to use it from nf_tables")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 373486a..57f15a9 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -844,8 +844,8 @@ config NETFILTER_XT_TARGET_RATEEST
 config NETFILTER_XT_TARGET_REDIRECT
 	tristate "REDIRECT target support"
 	depends on NF_NAT
-	select NF_NAT_REDIRECT_IPV4
-	select NF_NAT_REDIRECT_IPV6 if IP6_NF_IPTABLES
+	select NF_NAT_REDIRECT_IPV4 if NF_NAT_IPV4
+	select NF_NAT_REDIRECT_IPV6 if NF_NAT_IPV6
 	---help---
 	REDIRECT is a special case of NAT: all incoming connections are
 	mapped onto the incoming interface's address, causing the packets to
-- 
1.7.10.4
