From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: [PATCH net-next] vxlan: if_arp: introduce ARPHRD_VXLANGPE
Date: Thu,  5 May 2016 13:36:44 -0300
Message-ID: <1462466204-3534-1-git-send-email-cascardo@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43323 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757562AbcEEQg5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 12:36:57 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F0D05C04B303
	for <netdev@vger.kernel.org>; Thu,  5 May 2016 16:36:56 +0000 (UTC)
Received: from indiana.gru.redhat.com (ovpn-113-123.phx2.redhat.com [10.3.113.123])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u45GatCX000480
	for <netdev@vger.kernel.org>; Thu, 5 May 2016 12:36:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use ARPHRD_VXLANGPE to identify VxLAN GPE interfaces. This is going to be used
to allow GPE interfaces to be added as openvswitch ports.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Cc: Jiri Benc <jbenc@redhat.com>
Cc: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/vxlan.c         | 2 +-
 include/uapi/linux/if_arp.h | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 2668e52..9da962f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2603,7 +2603,7 @@ static void vxlan_ether_setup(struct net_device *dev)
 static void vxlan_raw_setup(struct net_device *dev)
 {
 	dev->header_ops = NULL;
-	dev->type = ARPHRD_NONE;
+	dev->type = ARPHRD_VXLANGPE;
 	dev->hard_header_len = 0;
 	dev->addr_len = 0;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
diff --git a/include/uapi/linux/if_arp.h b/include/uapi/linux/if_arp.h
index 4d024d7..52a8175 100644
--- a/include/uapi/linux/if_arp.h
+++ b/include/uapi/linux/if_arp.h
@@ -95,6 +95,7 @@
 #define ARPHRD_IP6GRE	823		/* GRE over IPv6		*/
 #define ARPHRD_NETLINK	824		/* Netlink header		*/
 #define ARPHRD_6LOWPAN	825		/* IPv6 over LoWPAN             */
+#define ARPHRD_VXLANGPE 826		/* VxLAN GPE */
 
 #define ARPHRD_VOID	  0xFFFF	/* Void type, nothing is known */
 #define ARPHRD_NONE	  0xFFFE	/* zero header length */
-- 
2.5.5
