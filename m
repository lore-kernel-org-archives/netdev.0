From: Bart De Schuymer <bdschuym@pandora.be>
Subject: [PATCH]
Date: Sat, 27 Dec 2003 14:50:18 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312271450.18115.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

We should also filter vlan-tagged IP/ARP traffic even if the vlan code
isn't compiled into the kernel. The patch below removes an unnecessary
dependence on the vlan code being compiled.

cheers,
Bart


--- linux-2.6.0/include/linux/netfilter_bridge.h.earlier	2003-12-25 17:01:38.000000000 +0100
+++ linux-2.6.0/include/linux/netfilter_bridge.h	2003-12-25 17:02:56.000000000 +0100
@@ -71,12 +71,10 @@ static inline
 void nf_bridge_maybe_copy_header(struct sk_buff *skb)
 {
 	if (skb->nf_bridge) {
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 		if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
 			memcpy(skb->data - 18, skb->nf_bridge->data, 18);
 			skb_push(skb, 4);
 		} else
-#endif
 			memcpy(skb->data - 16, skb->nf_bridge->data, 16);
 	}
 }
@@ -86,10 +84,9 @@ void nf_bridge_save_header(struct sk_buf
 {
         int header_size = 16;
 
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 	if (skb->protocol == __constant_htons(ETH_P_8021Q))
 		header_size = 18;
-#endif
+
 	memcpy(skb->nf_bridge->data, skb->data - header_size, header_size);
 }
 
