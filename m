From: Olof Johansson <olof@lixom.net>
Subject: [PATCH 6/9] pasemi_mac: Simplify memcpy for short receives
Date: Fri, 22 Jun 2007 15:05:36 -0500
Message-ID: <20070622200536.GG11723@lixom.net>
References: <20070622194720.614405000@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:59221 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751352AbXFVUHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2007 16:07:18 -0400
Content-Disposition: inline; filename=pasemi_mac-bugfix
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need to copy over the skipped align bytes (besides, NET_IP_ALIGN is
0 on ppc64).

Signed-off-by: Olof Johansson <olof@lixom.net>


Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -516,9 +516,7 @@ static int pasemi_mac_clean_rx(struct pa
 			    netdev_alloc_skb(mac->netdev, len + NET_IP_ALIGN);
 			if (new_skb) {
 				skb_reserve(new_skb, NET_IP_ALIGN);
-				memcpy(new_skb->data - NET_IP_ALIGN,
-					skb->data - NET_IP_ALIGN,
-					len + NET_IP_ALIGN);
+				memcpy(new_skb->data, skb->data, len);
 				/* save the skb in buffer_info as good */
 				skb = new_skb;
 			}

--
