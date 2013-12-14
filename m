From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] vxlan: make get_rx_port static
Date: Fri, 13 Dec 2013 16:37:22 -0800
Message-ID: <20131213163722.498f6e56@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:41316 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755Ab3LNAh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 19:37:26 -0500
Received: by mail-pd0-f175.google.com with SMTP id w10so3146955pde.20
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 16:37:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make local function static, only used in vxlan itself right now.
Maybe someone had ideas about offload, but they can expose it when
they send their offload upstream.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/vxlan.c	2013-12-12 11:48:17.057855220 -0800
+++ b/drivers/net/vxlan.c	2013-12-12 11:56:55.949774139 -0800
@@ -2039,7 +2039,7 @@ static struct device_type vxlan_type = {
  * supply the listening VXLAN udp ports. Callers are expected
  * to implement the ndo_add_vxlan_port.
  */
-void vxlan_get_rx_port(struct net_device *dev)
+static void vxlan_get_rx_port(struct net_device *dev)
 {
 	struct vxlan_sock *vs;
 	struct net *net = dev_net(dev);
--- a/include/net/vxlan.h	2013-12-12 11:48:17.057855220 -0800
+++ b/include/net/vxlan.h	2013-12-12 11:56:55.949774139 -0800
@@ -41,11 +41,4 @@ __be16 vxlan_src_port(__u16 port_min, __
 /* IPv6 header + UDP + VXLAN + Ethernet header */
 #define VXLAN6_HEADROOM (40 + 8 + 8 + 14)
 
-#if IS_ENABLED(CONFIG_VXLAN)
-void vxlan_get_rx_port(struct net_device *netdev);
-#else
-static inline void vxlan_get_rx_port(struct net_device *netdev)
-{
-}
-#endif
 #endif
