From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 2/8] lec: use IS_ENABLED() instead of checking for built-in or module
Date: Fri,  9 Sep 2016 08:43:14 -0400
Message-ID: <1473425000-9782-3-git-send-email-javier@osg.samsung.com>
References: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        Felipe Balbi <felipe.balbi@linux.intel.com>,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>,
        Antonio Quartulli <a@unstable.cc>,
        Mugunthan V N <mugunthanvnm@ti.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
built-in or as a module, use that macro instead of open coding the same.

Using the macro makes the code more readable by helping abstract away some
of the Kconfig built-in and module enable details.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 net/atm/lec.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index e574a7e9db6f..5d2693826afb 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -31,7 +31,7 @@
 #include <linux/atmlec.h>
 
 /* Proxy LEC knows about bridging */
-#if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
+#if IS_ENABLED(CONFIG_BRIDGE)
 #include "../bridge/br_private.h"
 
 static unsigned char bridge_ula_lec[] = { 0x01, 0x80, 0xc2, 0x00, 0x00 };
@@ -121,7 +121,7 @@ static unsigned char bus_mac[ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
 /* Device structures */
 static struct net_device *dev_lec[MAX_LEC_ITF];
 
-#if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
+#if IS_ENABLED(CONFIG_BRIDGE)
 static void lec_handle_bridge(struct sk_buff *skb, struct net_device *dev)
 {
 	char *buff;
@@ -155,7 +155,7 @@ static void lec_handle_bridge(struct sk_buff *skb, struct net_device *dev)
 		sk->sk_data_ready(sk);
 	}
 }
-#endif /* defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE) */
+#endif /* IS_ENABLED(CONFIG_BRIDGE) */
 
 /*
  * Open/initialize the netdevice. This is called (in the current kernel)
@@ -222,7 +222,7 @@ static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 	pr_debug("skbuff head:%lx data:%lx tail:%lx end:%lx\n",
 		 (long)skb->head, (long)skb->data, (long)skb_tail_pointer(skb),
 		 (long)skb_end_pointer(skb));
-#if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
+#if IS_ENABLED(CONFIG_BRIDGE)
 	if (memcmp(skb->data, bridge_ula_lec, sizeof(bridge_ula_lec)) == 0)
 		lec_handle_bridge(skb, dev);
 #endif
@@ -426,7 +426,7 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 		    (unsigned short)(0xffff & mesg->content.normal.flag);
 		break;
 	case l_should_bridge:
-#if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
+#if IS_ENABLED(CONFIG_BRIDGE)
 	{
 		pr_debug("%s: bridge zeppelin asks about %pM\n",
 			 dev->name, mesg->content.proxy.mac_addr);
@@ -452,7 +452,7 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 			sk->sk_data_ready(sk);
 		}
 	}
-#endif /* defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE) */
+#endif /* IS_ENABLED(CONFIG_BRIDGE) */
 		break;
 	default:
 		pr_info("%s: Unknown message type %d\n", dev->name, mesg->type);
-- 
2.7.4
