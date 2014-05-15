From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v2] net: tunnels - enable module autoloading
Date: Thu, 15 May 2014 23:21:30 +0200
Message-ID: <1400188890-2038-1-git-send-email-teg@jklm.no>
References: <20140515.153721.2222505094570361361.davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org, kaber@trash.net,
	yoshfuji@linux-ipv6.org, jmorris@namei.org, kuznet@ms2.inr.ac.ru,
	davem@davemloft.net, Tom Gundersen <teg@jklm.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:50885 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756025AbaEOVVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 17:21:41 -0400
Received: by mail-ee0-f53.google.com with SMTP id c13so1016407eek.12
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 14:21:40 -0700 (PDT)
In-Reply-To: <20140515.153721.2222505094570361361.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable the module alias hookup to allow tunnel modules to be autoloaded on demand.

This is in line with how most other netdev kinds work, and will allow userspace
to create tunnels without having CAP_SYS_MODULE.

Signed-off-by: Tom Gundersen <teg@jklm.no>
---
v2: add ';'

Hi Dave,

I must have sent out the wrong version of this patch. Sorry for the inconvenience!

Cheers,

Tom

 net/ipv4/ipip.c       | 1 +
 net/ipv6/ip6_tunnel.c | 1 +
 net/ipv6/sit.c        | 1 +
 3 files changed, 3 insertions(+)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 812b183..4bc508f 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -486,4 +486,5 @@ static void __exit ipip_fini(void)
 module_init(ipip_init);
 module_exit(ipip_fini);
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_RTNL_LINK("ipip");
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
