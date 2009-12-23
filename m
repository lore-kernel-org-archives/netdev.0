From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v2] llc enhancements
Date: Thu, 24 Dec 2009 01:45:25 +0200
Message-ID: <1261611934-24348-1-git-send-email-opurdila@ixiacom.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:23684 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757510AbZLWXsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:48:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies the LLC code to scale the socket lookup code for a
large number of interfaces and large number of sockets bound to the
same SAP. We use it for STP traffic generation from a large number of
virtual STP ports, via virtual network interfaces.

In the process we converted the socket lookup code and sap list to use
RCU. It also contains some general cleanups (use dev_hard_header
instead of handcrafting the headers) and enhancements (LLC_OPT_PKTINFO).

This is the 2nd version. Changes from the previous version:

- added SO_BINDTODEVICE support for faster bind operations
- converted the socket lookup code and sap list to RCU
- optimized multicast delivery ala Eric
- remove some unused APIs (which should be private anyway)

Many thanks to Eric Dumazet for his continuous guidance and to Jarek
Poplawski for spotting a locking bug in the previous version.


