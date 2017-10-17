From: Henrik Austad <henrik@austad.us>
Subject: [PATCH] net: export netdev_txq_to_tc to allow sch_mqprio to compile as module
Date: Tue, 17 Oct 2017 12:10:10 +0200
Message-ID: <1508235010-4056-1-git-send-email-haustad@cisco.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsahern@gmail.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Willem de Bruijn <willemb@google.com>,
        John Fastabend <john.fastabend@gmail.com>,
        tcharding <me@tobin.cc>, linux-kernel@vger.kernel.org,
        Henrik Austad <haustad@cisco.com>,
        Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In commit 32302902ff09 ("mqprio: Reserve last 32 classid values for HW
traffic classes and misc IDs") sch_mqprio started using netdev_txq_to_tc
to find the correct tc instead of dev->tc_to_txq[]

However, when mqprio is compiled as a module, it cannot resolve the
symbol, leading to this error:

     ERROR: "netdev_txq_to_tc" [net/sched/sch_mqprio.ko] undefined!

This adds an EXPORT_SYMBOL() since the other user in the kernel
(netif_set_xps_queue) is also EXPORT_SYMBOL() (and not _GPL) or in a
sysfs-callback.

Cc: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Henrik Austad <haustad@cisco.com>
---
 net/core/dev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index fcddccb..d2b20e7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2040,6 +2040,7 @@ int netdev_txq_to_tc(struct net_device *dev, unsigned int txq)
 
 	return 0;
 }
+EXPORT_SYMBOL(netdev_txq_to_tc);
 
 #ifdef CONFIG_XPS
 static DEFINE_MUTEX(xps_map_mutex);
-- 
2.7.4
