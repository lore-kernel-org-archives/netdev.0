From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 1/5] Cut off br_port fied from net_device
Date: Mon, 22 Oct 2007 16:33:33 +0400
Message-ID: <471C989D.9030207@openvz.org>
References: <471C9830.5070407@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:38934 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752018AbXJVMcv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 08:32:51 -0400
In-Reply-To: <471C9830.5070407@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

And add the forward declaration for br_handle_frame_hook in
include/linux/if_bridge.h

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 58e43e5..a718586 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -104,6 +104,8 @@ struct __fdb_entry
 
 #include <linux/netdevice.h>
 
+struct net_bridge_port;
+
 extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
 extern struct sk_buff *(*br_handle_frame_hook)(struct net_bridge_port *p,
 					       struct sk_buff *skb);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4a3f54e..469e04f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -699,8 +699,10 @@ struct net_device
 	/* Network namespace this network device is inside */
 	struct net		*nd_net;
 
+#if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
 	/* bridge stuff */
 	struct net_bridge_port	*br_port;
+#endif
 	/* macvlan */
 	struct macvlan_port	*macvlan_port;
 
-- 
1.5.3.4

