From: pablo@netfilter.org
Subject: [PATCH 2/3] netfilter: fix missing dependencies for the NOTRACK target
Date: Mon,  7 Jan 2013 21:04:06 +0100
Message-ID: <1357589047-3373-3-git-send-email-pablo@netfilter.org>
References: <1357589047-3373-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57393 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755476Ab3AGUEV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2013 15:04:21 -0500
In-Reply-To: <1357589047-3373-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

warning: (NETFILTER_XT_TARGET_NOTRACK) selects NETFILTER_XT_TARGET_CT which has unmet direct
+dependencies (NET && INET && NETFILTER && NETFILTER_XTABLES && NF_CONNTRACK && (IP_NF_RAW ||
+IP6_NF_RAW) && NETFILTER_ADVANCED)

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Acked-by: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 390f96c..49e96df 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -682,6 +682,9 @@ config NETFILTER_XT_TARGET_NFQUEUE
 
 config NETFILTER_XT_TARGET_NOTRACK
 	tristate  '"NOTRACK" target support (DEPRECATED)'
+	depends on NF_CONNTRACK
+	depends on IP_NF_RAW || IP6_NF_RAW
+	depends on NETFILTER_ADVANCED
 	select NETFILTER_XT_TARGET_CT
 
 config NETFILTER_XT_TARGET_RATEEST
-- 
1.7.10.4
