From: "Zoltan, Kiss" <schaman@sch.bme.hu>
Subject: [PATCH 1/1] IPv4: Send gratuitous ARP for secondary IP addresses also
Date: Mon, 25 Jul 2011 01:09:30 +0200
Message-ID: <1311548970-27522-1-git-send-email-schaman@sch.bme.hu>
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, Zoltan Kiss <schaman@sch.bme.hu>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Pekka Savola <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linu
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:46450 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751333Ab1GYAJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jul 2011 20:09:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zoltan Kiss <schaman@sch.bme.hu>

If a device event generates gratuitous ARP messages, only primary
address is used for sending. This patch iterates through the whole
list. Tested with 2 IP addresses configuration on bonding interface.

Signed-off-by: Zoltan Kiss <schaman@sch.bme.hu>
---
 net/ipv4/devinet.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 37b3c18..bc19bd0 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1134,15 +1134,15 @@ static void inetdev_send_gratuitous_arp(struct net_device *dev,
 					struct in_device *in_dev)
 
 {
-	struct in_ifaddr *ifa = in_dev->ifa_list;
-
-	if (!ifa)
-		return;
+	struct in_ifaddr *ifa;
 
-	arp_send(ARPOP_REQUEST, ETH_P_ARP,
-		 ifa->ifa_local, dev,
-		 ifa->ifa_local, NULL,
-		 dev->dev_addr, NULL);
+	for (ifa = in_dev->ifa_list; ifa;
+	     ifa = ifa->ifa_next) {
+		arp_send(ARPOP_REQUEST, ETH_P_ARP,
+			 ifa->ifa_local, dev,
+			 ifa->ifa_local, NULL,
+			 dev->dev_addr, NULL);
+	}
 }
 
 /* Called only under RTNL semaphore */
-- 
1.7.4.1

