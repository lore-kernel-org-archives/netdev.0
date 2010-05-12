From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH] arp_notify: generate broadcast ARP reply not request.
Date: Wed, 12 May 2010 14:40:28 +0100
Message-ID: <1273671629-15577-1-git-send-email-ian.campbell@citrix.com>
References: <1273671554.7572.11190.camel@zakaz.uk.xensource.com>
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>,
	"David S. Miller" <davem@davemloft.net>, stable@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:42636 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091Ab0ELNtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 09:49:18 -0400
In-Reply-To: <1273671554.7572.11190.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The arp_notify option causes us to send a broadcast ARP request
with the host IP address in both the source and destination IP address
fields. More usually a gratuitous ARP packet is a broadcast ARP reply
with a broadcast destination IP and the local IP as the source

The documentation of the arp_notify option in
Documentation/networking/ip-sysctl.txt suggests this was the original
intention therefore switch it over.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: stable@kernel.org
---
 net/ipv4/devinet.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 90e3d63..e26f723 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1087,10 +1087,10 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 			struct in_ifaddr *ifa = in_dev->ifa_list;
 
 			if (ifa)
-				arp_send(ARPOP_REQUEST, ETH_P_ARP,
-					 ifa->ifa_address, dev,
-					 ifa->ifa_address, NULL,
-					 dev->dev_addr, NULL);
+				arp_send(ARPOP_REPLY, ETH_P_ARP,
+					 INADDR_BROADCAST, dev,
+					 ifa->ifa_address,
+					 NULL, NULL, dev->dev_addr);
 		}
 		break;
 	case NETDEV_DOWN:
-- 
1.5.6.5

