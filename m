From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH 3/5] geneve: Rename support library as geneve_core
Date: Fri,  8 May 2015 13:20:55 -0400
Message-ID: <1431105657-25492-4-git-send-email-linville@tuxdriver.com>
References: <1431105657-25492-1-git-send-email-linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49264 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932480AbbEHRWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 13:22:11 -0400
In-Reply-To: <1431105657-25492-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/ipv4/geneve.c -> net/ipv4/geneve_core.c

This name better reflects the purpose of the module.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
Also, it prevents name resolution issues with module loading for the
geneve netdev coming later in this series...

 net/ipv4/Kconfig                     | 4 ++--
 net/ipv4/Makefile                    | 2 +-
 net/ipv4/{geneve.c => geneve_core.c} | 0
 net/openvswitch/Kconfig              | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)
 rename net/ipv4/{geneve.c => geneve_core.c} (100%)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index bd2901604842..d83071dccd74 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -331,8 +331,8 @@ config NET_FOU_IP_TUNNELS
 	  When this option is enabled IP tunnels can be configured to use
 	  FOU or GUE encapsulation.
 
-config GENEVE
-	tristate "Generic Network Virtualization Encapsulation (Geneve)"
+config GENEVE_CORE
+	tristate "Generic Network Virtualization Encapsulation library"
 	depends on INET
 	select NET_UDP_TUNNEL
 	---help---
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 518c04ed666e..b36236dd6014 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -56,7 +56,7 @@ obj-$(CONFIG_TCP_CONG_YEAH) += tcp_yeah.o
 obj-$(CONFIG_TCP_CONG_ILLINOIS) += tcp_illinois.o
 obj-$(CONFIG_MEMCG_KMEM) += tcp_memcontrol.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
-obj-$(CONFIG_GENEVE) += geneve.o
+obj-$(CONFIG_GENEVE_CORE) += geneve_core.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o xfrm4_protocol.o
diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve_core.c
similarity index 100%
rename from net/ipv4/geneve.c
rename to net/ipv4/geneve_core.c
diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index ed6b0f8dd1bb..15840401a2ce 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -59,7 +59,7 @@ config OPENVSWITCH_VXLAN
 config OPENVSWITCH_GENEVE
 	tristate "Open vSwitch Geneve tunneling support"
 	depends on OPENVSWITCH
-	depends on GENEVE
+	depends on GENEVE_CORE
 	default OPENVSWITCH
 	---help---
 	  If you say Y here, then the Open vSwitch will be able create geneve vport.
-- 
2.1.0
