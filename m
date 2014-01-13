From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH] netfilter: Add dependency on IPV6 for NF_TABLES_INET
Date: Mon, 13 Jan 2014 13:01:10 -0500
Message-ID: <1389636070-26312-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netfilter@vger.kernel.org>, <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: "David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:36146 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814AbaAMSBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 13:01:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 1d49144c0aaa61be4e3ccbef9cc5c40b0ec5f2fe ("netfilter: nf_tables:
add "inet" table for IPv4/IPv6") allows creation of non-IPV6 enabled
.config files that will fail to configure/link as follows:

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

Cc: Patrick McHardy <kaber@trash.net>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index afe50c0f526f..c37467562fd0 100644
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
1.8.5.2
