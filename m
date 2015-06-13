From: sfeldma@gmail.com
Subject: [RFC PATCH net-next 4/4] switchdev: update documentation for fwd_mark
Date: Sat, 13 Jun 2015 11:04:30 -0700
Message-ID: <1434218670-43821-5-git-send-email-sfeldma@gmail.com>
References: <1434218670-43821-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com,
	roopa@cumulusnetworks.com, ronen.arad@intel.com,
	john.r.fastabend@intel.com, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, davidch@broadcom.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:38242 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753176AbbFMSCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2015 14:02:43 -0400
Received: by igblz2 with SMTP id lz2so28136575igb.1
        for <netdev@vger.kernel.org>; Sat, 13 Jun 2015 11:02:43 -0700 (PDT)
In-Reply-To: <1434218670-43821-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 Documentation/networking/switchdev.txt |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index da82cd7..d6a8695 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -286,8 +286,17 @@ and unknown unicast packets to all ports in domain, if allowed by port's
 current STP state.  The switch driver, knowing which ports are within which
 vlan L2 domain, can program the switch device for flooding.  The packet should
 also be sent to the port netdev for processing by the bridge driver.  The
-bridge should not reflood the packet to the same ports the device flooded.
-XXX: the mechanism to avoid duplicate flood packets is being discuseed.
+bridge should not reflood the packet to the same ports the device flooded,
+otherwise there will be duplicate packets on the wire.
+
+To avoid duplicate packets, the device/driver can mark a packet as already
+forwarded using skb->fwd_mark.  The same mark is set on the device ports in the
+domain using dev->fwd_mark.  If the skb->fwd_mark is non-zero and matches the
+forwarding egress port's dev->skb_mark, the kernel will drop the skb right
+before transmit on the egress port, with the understanding that the device
+already forwarded the packet on same egress port.  The driver can use
+switchdev_mark_get() to get a globally unique mark for egress port(s)'
+dev->fwd_mark, based on a driver/device-supplied key.
 
 It is possible for the switch device to not handle flooding and push the
 packets up to the bridge driver for flooding.  This is not ideal as the number
-- 
1.7.10.4
