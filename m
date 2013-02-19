From: pablo@netfilter.org
Subject: [PATCH 1/7] netfilter: fix missing dependencies for NETFILTER_XT_MATCH_CONNLABEL
Date: Tue, 19 Feb 2013 01:10:45 +0100
Message-ID: <1361232651-5626-2-git-send-email-pablo@netfilter.org>
References: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slan-550-85.anhosting.com ([209.236.71.68]:31849 "EHLO
	slan-550-85.anhosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757230Ab3BSALL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 19:11:11 -0500
In-Reply-To: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

It was possible to set NF_CONNTRACK=n and NF_CONNTRACK_LABELS=y via
NETFILTER_XT_MATCH_CONNLABEL=y.

warning: (NETFILTER_XT_MATCH_CONNLABEL) selects NF_CONNTRACK_LABELS which has
unmet direct dependencies (NET && INET && NETFILTER && NF_CONNTRACK)

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index eb2c8eb..d4dd702 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -860,6 +860,7 @@ config NETFILTER_XT_MATCH_CONNBYTES
 config NETFILTER_XT_MATCH_CONNLABEL
 	tristate '"connlabel" match support'
 	select NF_CONNTRACK_LABELS
+	depends on NF_CONNTRACK
 	depends on NETFILTER_ADVANCED
 	---help---
 	  This match allows you to test and assign userspace-defined labels names
-- 
1.7.10.4
