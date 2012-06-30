From: John <linux@8192.net>
Subject: [PATCH V3 2/2] bonding support for IPv6 transmit hashing
Date: Fri, 29 Jun 2012 23:17:18 -0700
Message-ID: <4FEE99EE.2000001@8192.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp153.dfw.emailsrvr.com ([67.192.241.153]:44238 "EHLO
	smtp153.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507Ab2F3G0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 02:26:38 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by smtp32.relay.dfw1a.emailsrvr.com (SMTP Server) with ESMTP id 7F345504A4
	for <netdev@vger.kernel.org>; Sat, 30 Jun 2012 02:17:14 -0400 (EDT)
Received: by smtp32.relay.dfw1a.emailsrvr.com (Authenticated sender: john-AT-8192.net) with ESMTPSA id 4BD8850484
	for <netdev@vger.kernel.org>; Sat, 30 Jun 2012 02:17:14 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
