From: Tim Gardner <tim.gardner@canonical.com>
Subject: [PATCH net-next 1/1] net: neighbour: Simplify ifdefs around neigh_app_ns()
Date: Wed, 28 Aug 2013 12:24:46 -0600
Message-ID: <1377714286-51816-1-git-send-email-tim.gardner@canonical.com>
Cc: Tim Gardner <tim.gardner@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Joe Perches <joe@perches.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drop a couple of ifdef/endif pairs by moving the ifdef
surrounding neigh_app_ns() to the interior of neigh_app_ns().

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Joe Perches <joe@perches.com>
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---

This is an admittedly trivial change. I stumbled on it while trying to figure
out why Ubuntu doesn't have CONFIG_ARPD enabled.

 net/core/neighbour.c |    4 ++--
 net/ipv4/arp.c       |    2 --
 net/ipv6/ndisc.c     |    2 --
 3 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 60533db..049dd9e 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2759,13 +2759,13 @@ errout:
 		rtnl_set_sk_err(net, RTNLGRP_NEIGH, err);
 }
 
-#ifdef CONFIG_ARPD
 void neigh_app_ns(struct neighbour *n)
 {
+#ifdef CONFIG_ARPD
 	__neigh_notify(n, RTM_GETNEIGH, NLM_F_REQUEST);
+#endif /* CONFIG_ARPD */
 }
 EXPORT_SYMBOL(neigh_app_ns);
-#endif /* CONFIG_ARPD */
 
 #ifdef CONFIG_SYSCTL
 static int zero;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 4429b01..7808093 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -368,9 +368,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	} else {
 		probes -= neigh->parms->app_probes;
 		if (probes < 0) {
-#ifdef CONFIG_ARPD
 			neigh_app_ns(neigh);
-#endif
 			return;
 		}
 	}
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 04d31c2..d5693ad 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -663,9 +663,7 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 		}
 		ndisc_send_ns(dev, neigh, target, target, saddr);
 	} else if ((probes -= neigh->parms->app_probes) < 0) {
-#ifdef CONFIG_ARPD
 		neigh_app_ns(neigh);
-#endif
 	} else {
 		addrconf_addr_solict_mult(target, &mcaddr);
 		ndisc_send_ns(dev, NULL, target, &mcaddr, saddr);
-- 
1.7.9.5
