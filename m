From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/21] uapi: ebtables: don't include linux/if.h
Date: Mon, 13 Apr 2015 21:29:54 +0200
Message-ID: <1428953401-4838-16-git-send-email-pablo@netfilter.org>
References: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

linux/if.h creates conflicts in userspace with net/if.h

By using it here we force userspace to use linux/if.h while
net/if.h may be needed.

Note that:

include/linux/netfilter_ipv4/ip_tables.h and
include/linux/netfilter_ipv6/ip6_tables.h

don't include linux/if.h and they also refer to IFNAMSIZ, so they are
expecting userspace to include use net/if.h from the client program.

Signed-off-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_bridge/ebtables.h      |    3 ++-
 include/uapi/linux/netfilter_bridge/ebtables.h |    2 --
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/netfilter_bridge/ebtables.h b/include/linux/netfilter_bridge/ebtables.h
index 34e7a2b..f1bd396 100644
--- a/include/linux/netfilter_bridge/ebtables.h
+++ b/include/linux/netfilter_bridge/ebtables.h
@@ -12,9 +12,10 @@
 #ifndef __LINUX_BRIDGE_EFF_H
 #define __LINUX_BRIDGE_EFF_H
 
+#include <linux/if.h>
+#include <linux/if_ether.h>
 #include <uapi/linux/netfilter_bridge/ebtables.h>
 
-
 /* return values for match() functions */
 #define EBT_MATCH 0
 #define EBT_NOMATCH 1
diff --git a/include/uapi/linux/netfilter_bridge/ebtables.h b/include/uapi/linux/netfilter_bridge/ebtables.h
index ba99336..773dfe8 100644
--- a/include/uapi/linux/netfilter_bridge/ebtables.h
+++ b/include/uapi/linux/netfilter_bridge/ebtables.h
@@ -12,9 +12,7 @@
 
 #ifndef _UAPI__LINUX_BRIDGE_EFF_H
 #define _UAPI__LINUX_BRIDGE_EFF_H
-#include <linux/if.h>
 #include <linux/netfilter_bridge.h>
-#include <linux/if_ether.h>
 
 #define EBT_TABLE_MAXNAMELEN 32
 #define EBT_CHAIN_MAXNAMELEN EBT_TABLE_MAXNAMELEN
-- 
1.7.10.4

