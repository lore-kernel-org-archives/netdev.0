From: sfeldma@gmail.com
Subject: [PATCH net-next 5/5] switchdev: update documentation for offload_fwd_mark
Date: Wed,  8 Jul 2015 16:16:43 -0700
Message-ID: <1436397403-62412-6-git-send-email-sfeldma@gmail.com>
References: <1436397403-62412-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:36336 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbbGHXOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 19:14:20 -0400
Received: by pddu5 with SMTP id u5so66029458pdd.3
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 16:14:19 -0700 (PDT)
In-Reply-To: <1436397403-62412-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 Documentation/networking/switchdev.txt |   14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index c5d7ade..b864e47 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -279,8 +279,18 @@ and unknown unicast packets to all ports in domain, if allowed by port's
 current STP state.  The switch driver, knowing which ports are within which
 vlan L2 domain, can program the switch device for flooding.  The packet should
 also be sent to the port netdev for processing by the bridge driver.  The
-bridge should not reflood the packet to the same ports the device flooded.
-XXX: the mechanism to avoid duplicate flood packets is being discuseed.
+bridge should not reflood the packet to the same ports the device flooded,
+otherwise there will be duplicate packets on the wire.
+
+To avoid duplicate packets, the device/driver can mark a packet as already
+forwarded using skb->offload_fwd_mark.  The same mark is set on the device
+ports in the domain using dev->offload_fwd_mark.  If the skb->offload_fwd_mark
+is non-zero and matches the forwarding egress port's dev->skb_mark, the kernel
+will drop the skb right before transmit on the egress port, with the
+understanding that the device already forwarded the packet on same egress port.
+The driver can use switchdev_port_fwd_mark_set() to set a globally unique mark
+for port's dev->offload_fwd_mark, based on the port's parent ID (switch ID) and
+a group ifindex.
 
 It is possible for the switch device to not handle flooding and push the
 packets up to the bridge driver for flooding.  This is not ideal as the number
-- 
1.7.10.4
