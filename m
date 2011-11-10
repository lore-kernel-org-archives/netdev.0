From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 6/6] [6LoWPAN] update documentation
Date: Thu, 10 Nov 2011 20:41:11 +0300
Message-ID: <1320946871-7603-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111110173258.GA8056@avtobot.cybertron>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39214 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651Ab1KJRjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 12:39:49 -0500
Received: by wwe5 with SMTP id 5so3456wwe.1
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2011 09:39:48 -0800 (PST)
In-Reply-To: <20111110173258.GA8056@avtobot.cybertron>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds chapter to documentation which describes how to use
6lowpan technology.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 Documentation/networking/ieee802154.txt |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ieee802154.txt b/Documentation/networking/ieee802154.txt
index 23c995e..83cbee4 100644
--- a/Documentation/networking/ieee802154.txt
+++ b/Documentation/networking/ieee802154.txt
@@ -78,3 +78,30 @@ in software. This is currently WIP.
 
 See header include/net/mac802154.h and several drivers in drivers/ieee802154/.
 
+6LoWPAN Linux implementation
+============================
+
+The IEEE 802.15.4 standard specifies an MTU of 128 bytes, yielding about 80
+octets of actual MAC payload once security is turned on, on a wireless link
+with a link throughput of 250 kbps or less.  The 6LoWPAN adaptation format
+[RFC4944] was specified to carry IPv6 datagrams over such constrained links,
+taking into account limited bandwidth, memory, or energy resources that are
+expected in applications such as wireless Sensor Networks.  [RFC4944] defines
+a Mesh Addressing header to support sub-IP forwarding, a Fragmentation header
+to support the IPv6 minimum MTU requirement [RFC2460], and stateless header
+compression for IPv6 datagrams (LOWPAN_HC1 and LOWPAN_HC2) to reduce the
+relatively large IPv6 and UDP headers down to (in the best case) several bytes.
+
+In Semptember 2011 the standard update was published - [RFC6282].
+It deprecates HC1 and HC2 compression and defines IPHC encoding format which is
+used in this Linux implementation.
+
+All the code related to 6lowpan you may find in files: net/ieee802154/6lowpan.*
+
+To setup 6lowpan interface you need (busybox release > 1.17.0):
+1. Add IEEE802.15.4 interface and initialize PANid;
+2. Add 6lowpan interface by command like:
+   # ip link add link wpan0 name lowpan0 type lowpan
+3. Set MAC (if needs):
+   # ip link set lowpan0 address de:ad:be:ef:ca:fe:ba:be
+4. Bring up 'lowpan0' interface
-- 
1.7.2.5
