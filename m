From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH net-next 1/2] bridge: adding stubs for multicast exports
Date: Mon,  7 Jul 2014 05:41:16 +0200
Message-ID: <1404704477-19448-2-git-send-email-linus.luessing@web.de>
References: <1404704477-19448-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404704477-19448-1-git-send-email-linus.luessing@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To make users (e.g. batman-adv soon) load- and runnable even if the
bridge was compiled without snooping capabilities - or even if the
kernel was compiled without any bridge code at all.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 include/linux/if_bridge.h |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index fd22789..e0c575c 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -36,8 +36,22 @@ extern void brioctl_set(int (*ioctl_hook)(struct net=
 *, unsigned int, void __use
=20
 typedef int br_should_route_hook_t(struct sk_buff *skb);
 extern br_should_route_hook_t __rcu *br_should_route_hook;
+
+#if IS_ENABLED(CONFIG_BRIDGE) && IS_ENABLED(CONFIG_BRIDGE_IGMP_SNOOPIN=
G)
 int br_multicast_list_adjacent(struct net_device *dev,
 			       struct list_head *br_ip_list);
 bool br_multicast_has_querier_adjacent(struct net_device *dev, int pro=
to);
+#else
+static inline int br_multicast_list_adjacent(struct net_device *dev,
+					     struct list_head *br_ip_list)
+{
+	return 0;
+}
+static inline bool br_multicast_has_querier_adjacent(struct net_device=
 *dev,
+						     int proto)
+{
+	return false;
+}
+#endif
=20
 #endif
--=20
1.7.10.4
