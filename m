From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/6] netfilter: nf_dup: add missing dependencies with NF_CONNTRACK
Date: Mon, 14 Dec 2015 12:25:45 +0100
Message-ID: <1450092346-3281-6-git-send-email-pablo@netfilter.org>
References: <1450092346-3281-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1450092346-3281-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CONFIG_NF_CONNTRACK=m
CONFIG_NF_DUP_IPV4=y

results in:

   net/built-in.o: In function `nf_dup_ipv4':
>> (.text+0xd434f): undefined reference to `nf_conntrack_untracked'

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/Kconfig | 1 +
 net/ipv6/netfilter/Kconfig | 1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index a355841..c187c60 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -60,6 +60,7 @@ config NFT_REJECT_IPV4
 
 config NFT_DUP_IPV4
 	tristate "IPv4 nf_tables packet duplication support"
+	depends on !NF_CONNTRACK || NF_CONNTRACK
 	select NF_DUP_IPV4
 	help
 	  This module enables IPv4 packet duplication support for nf_tables.
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index f6a024e..e10a04c 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -49,6 +49,7 @@ config NFT_REJECT_IPV6
 
 config NFT_DUP_IPV6
 	tristate "IPv6 nf_tables packet duplication support"
+	depends on !NF_CONNTRACK || NF_CONNTRACK
 	select NF_DUP_IPV6
 	help
 	  This module enables IPv6 packet duplication support for nf_tables.
-- 
2.1.4

