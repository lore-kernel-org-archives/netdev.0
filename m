From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] ila: add NETFILTER dependency
Date: Fri, 18 Dec 2015 15:37:37 +0100
Message-ID: <2011239.T7zzuZGeyk@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Tom Herbert <tom@herbertland.com>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The recently added generic ILA translation facility fails to
build when CONFIG_NETFILTER is disabled:

net/ipv6/ila/ila_xlat.c:229:20: warning: 'struct nf_hook_state' declared inside parameter list
net/ipv6/ila/ila_xlat.c:235:27: error: array type has incomplete element type 'struct nf_hook_ops'
 static struct nf_hook_ops ila_nf_hook_ops[] __read_mostly = {

This adds an explicit Kconfig dependency to avoid that case.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 7f00feaf1076 ("ila: Add generic ILA translation facility")

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 983bb999738c..bb7dabe2ebbf 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -94,6 +94,7 @@ config IPV6_MIP6
 
 config IPV6_ILA
 	tristate "IPv6: Identifier Locator Addressing (ILA)"
+	depends on NETFILTER
 	select LWTUNNEL
 	---help---
 	  Support for IPv6 Identifier Locator Addressing (ILA).
