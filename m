From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH] net: tunnels - enable module autoloading
Date: Tue, 13 May 2014 10:48:28 +0200
Message-ID: <1399970908-9973-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, kaber@trash.net,
	yoshfuji@linux-ipv6.org, jmorris@namei.org, kuznet@ms2.inr.ac.ru,
	davem@davemloft.net, Tom Gundersen <teg@jklm.no>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable the module alias hookup to allow tunnel modules to be autoloaded on demand.

This is in line with how most other netdev kinds work, and will allow userspace
to create tunnels without having CAP_SYS_MODULE.

Signed-off-by: Tom Gundersen <teg@jklm.no>
Tested-by: Susant Sahani <susant@redhat.com>
---
 net/ipv4/ipip.c       | 1 +
 net/ipv6/ip6_tunnel.c | 1 +
 net/ipv6/sit.c        | 1 +
 3 files changed, 3 insertions(+)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 812b183..d8155cf 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -486,4 +486,5 @@ static void __exit ipip_fini(void)
 module_init(ipip_init);
 module_exit(ipip_fini);
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_RTNL_LINK("ipip")
 MODULE_ALIAS_NETDEV("tunl0");
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index b05b609..fe61545 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -61,6 +61,7 @@
 MODULE_AUTHOR("Ville Nuorvala");
 MODULE_DESCRIPTION("IPv6 tunneling device");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_RTNL_LINK("ip6tnl");
 MODULE_ALIAS_NETDEV("ip6tnl0");
 
 #ifdef IP6_TNL_DEBUG
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index e5a453c..f438004 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1828,4 +1828,5 @@ xfrm_tunnel_failed:
 module_init(sit_init);
 module_exit(sit_cleanup);
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_RTNL_LINK("sit");
 MODULE_ALIAS_NETDEV("sit0");
-- 
1.9.0
