From: John <linux@8192.net>
Subject: [PATCH 2/2] bonding: Doesn't support IPv6
Date: Fri, 28 Oct 2011 18:18:39 -0700
Message-ID: <4EAB546F.3060800@8192.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp191.iad.emailsrvr.com ([207.97.245.191]:53713 "EHLO
	smtp191.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932806Ab1J2BSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 21:18:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--- a/Documentation/networking/bonding.txt	2011-09-01 12:15:38.000000000 -0700
+++ b/Documentation/networking/bonding.txt	2011-09-26 10:23:43.000000000 -0700
@@ -709,12 +709,22 @@
  		protocol information to generate the hash.

  		Uses XOR of hardware MAC addresses and IP addresses to
-		generate the hash.  The formula is
+		generate the hash.  The IPv4 formula is

  		(((source IP XOR dest IP) AND 0xffff) XOR
  			( source MAC XOR destination MAC ))
  				modulo slave count

+        The IPv6 forumla is
+
+        iphash =
+             (source ip quad 2 XOR dest IP quad 2) XOR
+             (source ip quad 3 XOR dest IP quad 3) XOR
+             (source ip quad 4 XOR dest IP quad 4)
+
+        (iphash >> 16) XOR (iphash >> 8) XOR iphash
+            modulo slave count
+
  		This algorithm will place all traffic to a particular
  		network peer on the same slave.  For non-IP traffic,
  		the formula is the same as for the layer2 transmit
@@ -735,19 +745,30 @@
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
+			 (source ip quad 2 XOR dest IP quad 2) XOR
+			 (source ip quad 3 XOR dest IP quad 3) XOR
+			 (source ip quad 4 XOR dest IP quad 4)
+
+		((source port XOR dest port) XOR
+			 (iphash >> 16) XOR (iphash >> 8) XOR iphash
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
