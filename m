From: John Eaglesham <linux@8192.net>
Subject: [PATCH v4 2/2] Update bonding driver documentation to include IPv6 transmit hashing algorithm.
Date: Sun,  1 Jul 2012 00:01:39 -0700
Message-ID: <f9bff286392a4778369fa35dac2fafaff3d3a1b8.1341125875.git.linux@8192.net>
References: <cover.1341125875.git.linux@8192.net>
Cc: John Eaglesham <linux@8192.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp171.dfw.emailsrvr.com ([67.192.241.171]:45260 "EHLO
	smtp171.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835Ab2GAHCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 03:02:43 -0400
In-Reply-To: <cover.1341125875.git.linux@8192.net>
In-Reply-To: <cover.1341125875.git.linux@8192.net>
References: <cover.1341125875.git.linux@8192.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 Documentation/networking/bonding.txt | 31 ++++++++++++++++++++++++++-----
 1 file changed, 26 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index bfea8a3..5db14fe 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -752,12 +752,22 @@ xmit_hash_policy
 		protocol information to generate the hash.
 
 		Uses XOR of hardware MAC addresses and IP addresses to
-		generate the hash.  The formula is
+		generate the hash.  The IPv4 formula is
 
 		(((source IP XOR dest IP) AND 0xffff) XOR
 			( source MAC XOR destination MAC ))
 				modulo slave count
 
+		The IPv6 forumla is
+
+		iphash =
+			(source ip quad 2 XOR dest IP quad 2) XOR
+			(source ip quad 3 XOR dest IP quad 3) XOR
+			(source ip quad 4 XOR dest IP quad 4)
+
+		((iphash >> 16) XOR (iphash >> 8) XOR iphash)
+			modulo slave count
+
 		This algorithm will place all traffic to a particular
 		network peer on the same slave.  For non-IP traffic,
 		the formula is the same as for the layer2 transmit
@@ -778,19 +788,30 @@ xmit_hash_policy
 		slaves, although a single connection will not span
 		multiple slaves.
 
-		The formula for unfragmented TCP and UDP packets is
+		The formula for unfragmented IPv4 TCP and UDP packets is
 
 		((source port XOR dest port) XOR
 			 ((source IP XOR dest IP) AND 0xffff)
 				modulo slave count
 
-		For fragmented TCP or UDP packets and all other IP
-		protocol traffic, the source and destination port
+		The formula for unfragmented IPv6 TCP and UDP packets is
+
+		iphash =
+			(source ip quad 2 XOR dest IP quad 2) XOR
+			(source ip quad 3 XOR dest IP quad 3) XOR
+			(source ip quad 4 XOR dest IP quad 4)
+
+		((source port XOR dest port) XOR
+			(iphash >> 16) XOR (iphash >> 8) XOR iphash)
+				modulo slave count
+
+		For fragmented TCP or UDP packets and all other IPv4 and
+		IPv6 protocol traffic, the source and destination port
 		information is omitted.  For non-IP traffic, the
 		formula is the same as for the layer2 transmit hash
 		policy.
 
-		This policy is intended to mimic the behavior of
+		The IPv4 policy is intended to mimic the behavior of
 		certain switches, notably Cisco switches with PFC2 as
 		well as some Foundry and IBM products.
 
-- 
1.7.11
