From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v3 0/10] llc enhancements
Date: Sat, 26 Dec 2009 23:50:58 +0200
Message-ID: <1261864268-10460-1-git-send-email-opurdila@ixiacom.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:19502 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753030AbZLZVya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 16:54:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch set modifies the LLC code to scale the socket lookup code
for a large number of interfaces and large number of sockets bound to
the same SAP. We use it for STP traffic generation from a large number
of virtual STP ports, via virtual network interfaces.

In the process we converted the socket lookup code and sap list to use
RCU. It also contains some general cleanups (use dev_hard_header
instead of handcrafting the headers) and enhancements (LLC_OPT_PKTINFO).

This is the 3rd version. Changes from the 2nd version:
- fix a socket leak in the RCU lookup code
- add a socket counter per SAP to maintain socket sanity checks
- fix SAP ref counting w.r.t. socket handling

Changes from the 1st version:
- added SO_BINDTODEVICE support for faster bind operations
- converted the socket lookup code and sap list to RCU
- optimized multicast delivery ala Eric
- remove some unused APIs (which should be private anyway)
