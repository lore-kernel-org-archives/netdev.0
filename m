From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH] netfilter: fix missing dependencies in NETFILTER_XT_TARGET_LOG
Date: Tue,  2 Sep 2014 14:26:17 +0200
Message-ID: <1409660777-14999-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51842 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753692AbaIBMZf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 08:25:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

make defconfig reports:

warning: (NETFILTER_XT_TARGET_LOG) selects NF_LOG_IPV6 which has unmet direct dependencies (NET && INET && IPV6 && NETFILTER && NETFILTER_ADVANCED)

Fixes: d79a61d netfilter: NETFILTER_XT_TARGET_LOG selects NF_LOG_*
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
~
@David, if you pull this request:

http://patchwork.ozlabs.org/patch/385042/

Could you also manually apply this patch to calm down kbuild robot?

Thanks!

 net/ipv6/netfilter/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index cf0b88f..2812816 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -57,7 +57,7 @@ config NFT_REJECT_IPV6
 
 config NF_LOG_IPV6
 	tristate "IPv6 packet logging"
-	depends on NETFILTER_ADVANCED
+	default m if NETFILTER_ADVANCED=n
 	select NF_LOG_COMMON
 
 config NF_NAT_IPV6
-- 
1.7.10.4
