From: Andy Zhou <azhou@nicira.com>
Subject: [net-next] udp_tunnel: Only build ip6_udp_tunnel.c when IPV6 is selected
Date: Fri, 19 Sep 2014 18:02:53 -0700
Message-ID: <1411174973-323-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog136.obsmtp.com ([74.125.149.85]:34246 "HELO
	na3sys009aog136.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757376AbaITBIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 21:08:40 -0400
Received: by mail-pd0-f175.google.com with SMTP id z10so920062pdj.6
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 18:08:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Functions supplied in ip6_udp_tunnel.c are only needed when IPV6 is
selected. When IPV6 is not selected, those functions are stubbed out
in udp_tunnel.h.

==================================================================
 net/ipv6/ip6_udp_tunnel.c:15:5: error: redefinition of 'udp_sock_create6'
     int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
 In file included from net/ipv6/ip6_udp_tunnel.c:9:0:
      include/net/udp_tunnel.h:36:19: note: previous definition of 'udp_sock_create6' was here
       static inline int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
==================================================================

Fixes:  fd384412e udp_tunnel: Seperate ipv6 functions into its own file
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 net/ipv6/Makefile |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 45f830e..2e8c061 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -35,7 +35,6 @@ obj-$(CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION) += xfrm6_mode_ro.o
 obj-$(CONFIG_INET6_XFRM_MODE_BEET) += xfrm6_mode_beet.o
 obj-$(CONFIG_IPV6_MIP6) += mip6.o
 obj-$(CONFIG_NETFILTER)	+= netfilter/
-obj-$(CONFIG_NET_UDP_TUNNEL) += ip6_udp_tunnel.o
 
 obj-$(CONFIG_IPV6_VTI) += ip6_vti.o
 obj-$(CONFIG_IPV6_SIT) += sit.o
@@ -46,3 +45,7 @@ obj-y += addrconf_core.o exthdrs_core.o ip6_checksum.o ip6_icmp.o
 obj-$(CONFIG_INET) += output_core.o protocol.o $(ipv6-offload)
 
 obj-$(subst m,y,$(CONFIG_IPV6)) += inet6_hashtables.o
+
+ifneq ($(CONFIG_IPV6),)
+obj-$(CONFIG_NET_UDP_TUNNEL) += ip6_udp_tunnel.o
+endif
-- 
1.7.9.5
