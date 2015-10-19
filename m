From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/4] netfilter: fix Kconfig dependencies for nf_dup_ipv{4,6}
Date: Mon, 19 Oct 2015 20:22:52 +0200
Message-ID: <1445278975-2412-2-git-send-email-pablo@netfilter.org>
References: <1445278975-2412-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1445278975-2412-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net/built-in.o: In function `nf_dup_ipv4': (.text+0xed24d): undefined reference to `nf_conntrack_untracked'
net/built-in.o: In function `nf_dup_ipv4': (.text+0xed267): undefined reference to `nf_conntrack_untracked'
net/built-in.o: In function `nf_dup_ipv6': (.text+0x158aef): undefined reference to `nf_conntrack_untracked'
net/built-in.o: In function `nf_dup_ipv6': (.text+0x158b09): undefined reference to `nf_conntrack_untracked'

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/Kconfig | 1 +
 net/ipv6/netfilter/Kconfig | 1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 690d27d..a355841 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -75,6 +75,7 @@ endif # NF_TABLES
 
 config NF_DUP_IPV4
 	tristate "Netfilter IPv4 packet duplication to alternate destination"
+	depends on !NF_CONNTRACK || NF_CONNTRACK
 	help
 	  This option enables the nf_dup_ipv4 core, which duplicates an IPv4
 	  packet to be rerouted to another destination.
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 96833e4..f6a024e 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -58,6 +58,7 @@ endif # NF_TABLES
 
 config NF_DUP_IPV6
 	tristate "Netfilter IPv6 packet duplication to alternate destination"
+	depends on !NF_CONNTRACK || NF_CONNTRACK
 	help
 	  This option enables the nf_dup_ipv6 core, which duplicates an IPv6
 	  packet to be rerouted to another destination.
-- 
2.1.4

