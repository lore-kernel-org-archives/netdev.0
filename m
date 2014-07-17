From: Xie Jianhua <Jianhua.Xie@freescale.com>
Subject: [PATCH net v3 2/2] bonding: update bonding.txt for Layer2 hash factors
Date: Thu, 17 Jul 2014 14:16:26 +0800
Message-ID: <1405577786-28811-2-git-send-email-Jianhua.Xie@freescale.com>
References: <1405577786-28811-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jianhua Xie <jianhua.xie@freescale.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Pan Jiafei <Jiafei.Pan@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0212.outbound.protection.outlook.com ([207.46.163.212]:10329
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753658AbaGQGVA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2014 02:21:00 -0400
In-Reply-To: <1405577786-28811-1-git-send-email-Jianhua.Xie@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jianhua Xie <jianhua.xie@freescale.com>

Document the Layer 2 hash factors with packet type ID field.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: David S. Miller <davem@davemloft.net>
CC: Pan Jiafei <Jiafei.Pan@freescale.com>

Signed-off-by: Jianhua Xie <jianhua.xie@freescale.com>
---
 Documentation/networking/bonding.txt | 31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 9c723ec..eeb5b2e 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -542,10 +542,10 @@ mode
 
 		XOR policy: Transmit based on the selected transmit
 		hash policy.  The default policy is a simple [(source
-		MAC address XOR'd with destination MAC address) modulo
-		slave count].  Alternate transmit policies may be
-		selected via the xmit_hash_policy option, described
-		below.
+		MAC address XOR'd with destination MAC address XOR
+		packet type ID) modulo slave count].  Alternate transmit
+		policies may be	selected via the xmit_hash_policy option,
+		described below.
 
 		This mode provides load balancing and fault tolerance.
 
@@ -801,10 +801,11 @@ xmit_hash_policy
 
 	layer2
 
-		Uses XOR of hardware MAC addresses to generate the
-		hash.  The formula is
+		Uses XOR of hardware MAC addresses and packet type ID
+		field to generate the hash. The formula is
 
-		(source MAC XOR destination MAC) modulo slave count
+		hash = source MAC XOR destination MAC XOR packet type ID
+		slave number = hash modulo slave count
 
 		This algorithm will place all traffic to a particular
 		network peer on the same slave.
@@ -819,7 +820,7 @@ xmit_hash_policy
 		Uses XOR of hardware MAC addresses and IP addresses to
 		generate the hash.  The formula is
 
-		hash = source MAC XOR destination MAC
+		hash = source MAC XOR destination MAC XOR packet type ID
 		hash = hash XOR source IP XOR destination IP
 		hash = hash XOR (hash RSHIFT 16)
 		hash = hash XOR (hash RSHIFT 8)
@@ -2301,13 +2302,13 @@ broadcast: Like active-backup, there is not much advantage to this
 	bandwidth.  
 
 	Additionally, the linux bonding 802.3ad implementation
-	distributes traffic by peer (using an XOR of MAC addresses),
-	so in a "gatewayed" configuration, all outgoing traffic will
-	generally use the same device.  Incoming traffic may also end
-	up on a single device, but that is dependent upon the
-	balancing policy of the peer's 8023.ad implementation.  In a
-	"local" configuration, traffic will be distributed across the
-	devices in the bond.
+	distributes traffic by peer (using an XOR of MAC addresses
+	and packet type ID), so in a "gatewayed" configuration, all
+	outgoing traffic will generally use the same device.  Incoming
+	traffic may also end up on a single device, but that is
+	dependent upon the balancing policy of the peer's 8023.ad
+	implementation.  In a "local" configuration, traffic will be
+	distributed across the devices in the bond.
 
 	Finally, the 802.3ad mode mandates the use of the MII monitor,
 	therefore, the ARP monitor is not available in this mode.
-- 
1.8.5
