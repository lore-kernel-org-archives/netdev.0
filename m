From: raj@tardy.usa.hp.com (Rick Jones)
Subject: [PATCH v2 net-next] documentation: bring vxlan documentation more up-to-date
Date: Wed, 12 Aug 2015 10:23:14 -0700 (PDT)
Message-ID: <20150812172314.5C6862900958@tardy>
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hp.com ([15.240.0.71]:51054 "EHLO
	g9t1613g.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932279AbbHLRXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 13:23:24 -0400
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com [15.216.225.55])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g9t1613g.houston.hp.com (Postfix) with ESMTPS id 9BD1F6751D
	for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 17:23:16 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

A few things have changed since the previous version of the vxlan
documentation was written, so update it and correct some grammer and
such while we are at it.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

v2: Stephen Hemminger feedback to include dstport 4789 in command line
    example.  Also some further refinements from other sources.

diff --git a/Documentation/networking/vxlan.txt b/Documentation/networking/vxlan.txt
index 6d99351..89ee11b 100644
--- a/Documentation/networking/vxlan.txt
+++ b/Documentation/networking/vxlan.txt
@@ -1,32 +1,36 @@
 Virtual eXtensible Local Area Networking documentation
 ======================================================
 
-The VXLAN protocol is a tunnelling protocol that is designed to
-solve the problem of limited number of available VLAN's (4096).
-With VXLAN identifier is expanded to 24 bits.
-
-It is a draft RFC standard, that is implemented by Cisco Nexus,
-Vmware and Brocade. The protocol runs over UDP using a single
-destination port (still not standardized by IANA).
-This document describes the Linux kernel tunnel device,
-there is also an implantation of VXLAN for Openvswitch.
-
-Unlike most tunnels, a VXLAN is a 1 to N network, not just point
-to point. A VXLAN device can either dynamically learn the IP address
-of the other end, in a manner similar to a learning bridge, or the
-forwarding entries can be configured statically.
-
-The management of vxlan is done in a similar fashion to it's
-too closest neighbors GRE and VLAN. Configuring VXLAN requires
-the version of iproute2 that matches the kernel release
-where VXLAN was first merged upstream.
+The VXLAN protocol is a tunnelling protocol designed to solve the
+problem of limited VLAN IDs (4096) in IEEE 802.1q.  With VXLAN the
+size of the identifier is expanded to 24 bits (16777216).
+
+VXLAN is described by IETF RFC 7348, and has been implemented by a
+number of vendors.  The protocol runs over UDP using a single
+destination port.  This document describes the Linux kernel tunnel
+device, there is also a separate implementation of VXLAN for
+Openvswitch.
+
+Unlike most tunnels, a VXLAN is a 1 to N network, not just point to
+point. A VXLAN device can learn the IP address of the other endpoint
+either dynamically in a manner similar to a learning bridge, or make
+use of statically-configured forwarding entries.
+
+The management of vxlan is done in a manner similar to its two closest
+neighbors GRE and VLAN. Configuring VXLAN requires the version of
+iproute2 that matches the kernel release where VXLAN was first merged
+upstream.
 
 1. Create vxlan device
-  # ip li add vxlan0 type vxlan id 42 group 239.1.1.1 dev eth1
-
-This creates a new device (vxlan0). The device uses the
-the multicast group 239.1.1.1 over eth1 to handle packets where
-no entry is in the forwarding table.
+ # ip link add vxlan0 type vxlan id 42 group 239.1.1.1 dev eth1 dstport 4789
+
+This creates a new device named vxlan0.  The device uses the multicast
+group 239.1.1.1 over eth1 to handle traffic for which there is no
+entry in the forwarding table.  The destination port number is set to
+the IANA-assigned value of 4789.  The Linux implementation of VXLAN
+pre-dates the IANA's selection of a standard destination port number
+and uses the Linux-selected value by default to maintain backwards
+compatibility.
 
 2. Delete vxlan device
   # ip link delete vxlan0
