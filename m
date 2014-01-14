From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: Add dependency on IPV6 for NF_TABLES_INET
Date: Tue, 14 Jan 2014 11:35:42 +0000
Message-ID: <85d5725b-16f8-464a-ad88-7def74571021@email.android.com>
References: <1389636070-26312-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netfilter@vger.kernel.org, netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33594 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468AbaANLfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 06:35:54 -0500
In-Reply-To: <1389636070-26312-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Gortmaker <paul.gortmaker@windriver.com> schrieb:
>Commit 1d49144c0aaa61be4e3ccbef9cc5c40b0ec5f2fe ("netfilter: nf_tables:
>add "inet" table for IPv4/IPv6") allows creation of non-IPV6 enabled
>.config files that will fail to configure/link as follows:
>
>warning: (NF_TABLES_INET) selects NF_TABLES_IPV6 which has unmet direct
>dependencies (NET && INET && IPV6 && NETFILTER && NF_TABLES)
>warning: (NF_TABLES_INET) selects NF_TABLES_IPV6 which has unmet direct
>dependencies (NET && INET && IPV6 && NETFILTER && NF_TABLES)
>warning: (NF_TABLES_INET) selects NF_TABLES_IPV6 which has unmet direct
>dependencies (NET && INET && IPV6 && NETFILTER && NF_TABLES)
>net/built-in.o: In function `nft_reject_eval':
>nft_reject.c:(.text+0x651e8): undefined reference to `nf_ip6_checksum'
>nft_reject.c:(.text+0x65270): undefined reference to `ip6_route_output'
>nft_reject.c:(.text+0x656c4): undefined reference to `ip6_dst_hoplimit'
>make: *** [vmlinux] Error 1
>
>Since the feature is to allow for a mixed IPV4 and IPV6 table, it
>seems sensible to make it depend on IPV6.

Acked-by: Patrick McHardy <kaber@trash.net>

>
>Cc: Patrick McHardy <kaber@trash.net>
>Cc: Pablo Neira Ayuso <pablo@netfilter.org>
>Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
>
>diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
>index afe50c0f526f..c37467562fd0 100644
>--- a/net/netfilter/Kconfig
>+++ b/net/netfilter/Kconfig
>@@ -429,7 +429,7 @@ config NF_TABLES
> 	  To compile it as a module, choose M here.
> 
> config NF_TABLES_INET
>-	depends on NF_TABLES
>+	depends on NF_TABLES && IPV6
> 	select NF_TABLES_IPV4
> 	select NF_TABLES_IPV6
> 	tristate "Netfilter nf_tables mixed IPv4/IPv6 tables support"
