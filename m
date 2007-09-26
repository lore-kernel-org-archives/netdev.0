From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [2/6] pasemi_mac: fix build break in pasemi_mac_clean_rx()
Date: Wed, 26 Sep 2007 16:23:06 -0500
Message-ID: <20070926212306.GC24168@lixom.net>
References: <20070926212200.GA24168@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:41587 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754784AbXIZVT5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 17:19:57 -0400
Content-Disposition: inline
In-Reply-To: <20070926212200.GA24168@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: fix build break in pasemi_mac_clean_rx()

Fix breakage caused by the unification of stats structs.


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -530,8 +530,8 @@ static int pasemi_mac_clean_rx(struct pa
 		} else
 			skb->ip_summed = CHECKSUM_NONE;
 
-		dev->stats.rx_bytes += len;
-		dev->stats.rx_packets++;
+		mac->netdev->stats.rx_bytes += len;
+		mac->netdev->stats.rx_packets++;
 
 		skb->protocol = eth_type_trans(skb, mac->netdev);
 		netif_receive_skb(skb);
