From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 1/2] net: Make IPv6 build depend on CONFIG_INET
Date: Thu, 15 Nov 2012 21:34:57 -0500
Message-ID: <1353033297-2724-1-git-send-email-vyasevic@redhat.com>
References: <50a57815.U2EL8TTOk3ffGeV3%fengguang.wu@intel.com>
Cc: davem@davemloft.net, fengguang.wu@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40015 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750804Ab2KPCfN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 21:35:13 -0500
In-Reply-To: <50a57815.U2EL8TTOk3ffGeV3%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 build selection currently controlled by CONFIG_NET, so it is
possible to build IPv6 functinality without selectiona any TCP/IP
features (CONFIG_INET).  Make IPv6 be consistent with IPv4.

This should resolve the following issue:

net/built-in.o: In function `tcp6_gro_complete':
tcpv6_offload.c:(.text+0x3d045): undefined reference to
`tcp_gro_complete'
net/built-in.o: In function `tcp6_gro_receive':
tcpv6_offload.c:(.text+0x3d19b): undefined reference to
`tcp_gro_receive'
net/built-in.o: In function `ipv6_exthdrs_offload_init':
(.init.text+0x118b): undefined reference to `inet_del_offload'
net/built-in.o:(.rodata+0x1c58): undefined reference to
`tcp_tso_segment'

Signed-off-by: Vlad Yasevich <vyasvic@redhat.com>
---
 net/Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/Makefile b/net/Makefile
index 4f4ee08..e050d9d 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -19,7 +19,7 @@ obj-$(CONFIG_NETFILTER)		+= netfilter/
 obj-$(CONFIG_INET)		+= ipv4/
 obj-$(CONFIG_XFRM)		+= xfrm/
 obj-$(CONFIG_UNIX)		+= unix/
-obj-$(CONFIG_NET)		+= ipv6/
+obj-$(CONFIG_INET)		+= ipv6/
 obj-$(CONFIG_PACKET)		+= packet/
 obj-$(CONFIG_NET_KEY)		+= key/
 obj-$(CONFIG_BRIDGE)		+= bridge/
-- 
1.7.7.6
