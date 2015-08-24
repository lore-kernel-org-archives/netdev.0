From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH] man ip-link: Add little explanations about VLAN qos map
Date: Mon, 24 Aug 2015 17:57:06 +0300
Message-ID: <1440428226-21092-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36755 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754612AbbHXO74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 10:59:56 -0400
Received: by wicja10 with SMTP id ja10so74700296wic.1
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 07:59:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Add little more info about how to manually set priority by iptables,
and some little clarifications about ingress/egress QoS mapping.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip-link.8.in | 27 ++++++++++++++++++++++++---
 1 file changed, 24 insertions(+), 3 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index b9137fb..2283b71 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -349,10 +349,30 @@ where <phy_dev> is the physical device to which VLAN device is bound.
 - specifies whether the VLAN device state is bound to the physical device state.
 
 .BI ingress-qos-map " QOS-MAP "
-- defines a mapping between priority code points on incoming frames.  The format is FROM:TO with multiple mappings separated by spaces.
+- defines a mapping of VLAN header prio field to the Linux internal packet
+priority on incoming frames. The format is FROM:TO with multiple mappings
+separated by spaces.
 
 .BI egress-qos-map " QOS-MAP "
-- the same as ingress-qos-map but for outgoing frames.
+- defines a mapping of Linux internal packet priority to VLAN header prio field
+but for outgoing frames. The format is the same as for ingress-qos-map.
+.in +4
+
+Linux packet priority can be set by
+.BR iptables "(8)":
+.in +4
+.sp
+.B iptables
+-t mangle -A POSTROUTING [...] -j CLASSIFY --set-class 0:4
+.sp
+.in -4
+and this "4" priority can be used in the egress qos mapping to set VLAN prio "5":
+.sp
+.in +4
+.B ip
+link set veth0.10 type vlan egress 4:5
+.in -4
+.in -4
 .in -8
 
 .TP
@@ -1090,7 +1110,8 @@ IEEE 802.15.4 device wpan0.
 .br
 .BR ip (8),
 .BR ip-netns (8),
-.BR ethtool (8)
+.BR ethtool (8),
+.BR iptables (8)
 
 .SH AUTHOR
 Original Manpage by Michail Litvak <mci@owl.openwall.com>
-- 
2.4.2
