From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/3] netfilter: Add dependency on IPV6 for NF_TABLES_INET
Date: Thu, 16 Jan 2014 10:04:52 +0100
Message-ID: <1389863093-4530-3-git-send-email-pablo@netfilter.org>
References: <1389863093-4530-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1389863093-4530-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Gortmaker <paul.gortmaker@windriver.com>

Commit 1d49144c0aa ("netfilter: nf_tables: add "inet" table for
IPv4/IPv6") allows creation of non-IPV6 enabled .config files that
will fail to configure/link as follows:

warning: (NF_TABLES_INET) selects NF_TABLES_IPV6 which has unmet direct dependencies (NET && INET && IPV6 && NETFILTER && NF_TABLES)
warning: (NF_TABLES_INET) selects NF_TABLES_IPV6 which has unmet direct dependencies (NET && INET && IPV6 && NETFILTER && NF_TABLES)
warning: (NF_TABLES_INET) selects NF_TABLES_IPV6 which has unmet direct dependencies (NET && INET && IPV6 && NETFILTER && NF_TABLES)
net/built-in.o: In function `nft_reject_eval':
nft_reject.c:(.text+0x651e8): undefined reference to `nf_ip6_checksum'
nft_reject.c:(.text+0x65270): undefined reference to `ip6_route_output'
nft_reject.c:(.text+0x656c4): undefined reference to `ip6_dst_hoplimit'
make: *** [vmlinux] Error 1

Since the feature is to allow for a mixed IPV4 and IPV6 table, it
seems sensible to make it depend on IPV6.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Acked-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 37d2092..6941a4f 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -429,7 +429,7 @@ config NF_TABLES
 	  To compile it as a module, choose M here.
 
 config NF_TABLES_INET
-	depends on NF_TABLES
+	depends on NF_TABLES && IPV6
 	select NF_TABLES_IPV4
 	select NF_TABLES_IPV6
 	tristate "Netfilter nf_tables mixed IPv4/IPv6 tables support"
-- 
1.7.10.4

