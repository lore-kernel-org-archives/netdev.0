From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [net-next] ip_tunnel: fix building with NET_IP_TUNNEL=m
Date: Wed, 11 Oct 2017 15:55:31 +0200
Message-ID: <20171011135546.3536829-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When af_mpls is built-in but the tunnel support is a module,
we get a link failure:

net/mpls/af_mpls.o: In function `mpls_init':
af_mpls.c:(.init.text+0xdc): undefined reference to `ip_tunnel_encap_add_ops'

This adds a Kconfig statement to prevent the broken
configuration and force mpls to be a module as well in
this case.

Fixes: bdc476413dcd ("ip_tunnel: add mpls over gre support")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/mpls/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
index 5c467ef97311..801ea9098387 100644
--- a/net/mpls/Kconfig
+++ b/net/mpls/Kconfig
@@ -24,6 +24,7 @@ config NET_MPLS_GSO
 
 config MPLS_ROUTING
 	tristate "MPLS: routing support"
+	depends on NET_IP_TUNNEL || NET_IP_TUNNEL=n
 	---help---
 	 Add support for forwarding of mpls packets.
 
-- 
2.9.0
