From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net-next] netfilter: bridge: build br_nf_core only if required
Date: Tue, 30 Sep 2014 10:59:18 +0200
Message-ID: <1412067559-28733-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Eric reports build failure with
CONFIG_BRIDGE_NETFILTER=n

We insist to build br_nf_core.o unconditionally, but we must only do so
if br_netfilter was enabled, else it fails to build due to
functions being defined to empty stubs (and some structure members
being defined out).

Also, BRIDGE_NETFILTER=y|m makes no sense when BRIDGE=n.

Fixes: 34666d467 (netfilter: bridge: move br_netfilter out of the core)
Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/Kconfig         |    2 +-
 net/bridge/Makefile |    5 +++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index dc5d700..d6b138e 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -177,7 +177,7 @@ config NETFILTER_ADVANCED
 
 config BRIDGE_NETFILTER
 	tristate "Bridged IP/ARP packets filtering"
-	depends on (BRIDGE || BRIDGE=n)
+	depends on BRIDGE
 	depends on NETFILTER && INET
 	depends on NETFILTER_ADVANCED
 	default m
diff --git a/net/bridge/Makefile b/net/bridge/Makefile
index 5e3eac5..fd7ee03 100644
--- a/net/bridge/Makefile
+++ b/net/bridge/Makefile
@@ -6,11 +6,12 @@ obj-$(CONFIG_BRIDGE) += bridge.o
 
 bridge-y	:= br.o br_device.o br_fdb.o br_forward.o br_if.o br_input.o \
 			br_ioctl.o br_stp.o br_stp_bpdu.o \
-			br_stp_if.o br_stp_timer.o br_netlink.o \
-			br_nf_core.o
+			br_stp_if.o br_stp_timer.o br_netlink.o
 
 bridge-$(CONFIG_SYSFS) += br_sysfs_if.o br_sysfs_br.o
 
+bridge-$(subst m,y,$(CONFIG_BRIDGE_NETFILTER)) += br_nf_core.o
+
 obj-$(CONFIG_BRIDGE_NETFILTER) += br_netfilter.o
 
 bridge-$(CONFIG_BRIDGE_IGMP_SNOOPING) += br_multicast.o br_mdb.o
-- 
1.7.10.4

