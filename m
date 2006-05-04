From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] bridge: keep track of received multicast packets
Date: Thu, 4 May 2006 16:10:19 -0700
Message-ID: <20060504161019.17feb2aa@localhost.localdomain>
References: <20060504143624.324274f6@localhost.localdomain>
	<FFEPKIHJDEDDAAFOFDGFMEJGCBAA.PCDiem@FoxValley.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <bridge@lists.osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:33983 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932348AbWEDXis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 19:38:48 -0400
To: "Paul C. Diem" <PCDiem@foxvalley.net>,
	"David S. Miller" <davem@davemloft.net>
In-Reply-To: <FFEPKIHJDEDDAAFOFDGFMEJGCBAA.PCDiem@FoxValley.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It makes sense to add this simple statistic to keep track of received
multicast packets.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- bridge.orig/net/bridge/br_input.c	2006-04-21 14:28:55.000000000 -0700
+++ bridge/net/bridge/br_input.c	2006-05-04 16:07:24.000000000 -0700
@@ -66,6 +66,7 @@
 	}
 
 	if (is_multicast_ether_addr(dest)) {
+		br->statistics.multicast++;
 		br_flood_forward(br, skb, !passedup);
 		if (!passedup)
 			br_pass_frame_up(br, skb);
