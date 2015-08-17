From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH] man ip-link: Add more explanation about vlan reordering
Date: Mon, 17 Aug 2015 22:22:24 +0300
Message-ID: <1439839344-12772-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35050 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbbHQTZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 15:25:07 -0400
Received: by wicne3 with SMTP id ne3so78309259wic.0
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 12:25:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Add more explanation about VLAN reordering and what it affects.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip-link.8.in | 29 +++++++++++++++++++++++++++--
 1 file changed, 27 insertions(+), 2 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index df2fcce..b9137fb 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -313,7 +313,31 @@ the following additional arguments are supported:
 - specifies the VLAN Identifer to use. Note that numbers with a leading " 0 " or " 0x " are interpreted as octal or hexadeimal, respectively.
 
 .BR reorder_hdr " { " on " | " off " } "
-- specifies whether ethernet headers are reordered or not.
+- specifies whether ethernet headers are reordered or not (default is
+.BR on ")."
+
+.in +4
+If
+.BR reorder_hdr " is " on
+then VLAN header will be not inserted immediately but only before passing to the
+physical device (if this device does not support VLAN offloading), the similar
+on the RX direction - by default the packet will be untagged before being
+received by VLAN device. Reordering allows to accelerate tagging on egress and
+to hide VLAN header on ingress so the packet looks like regular Ethernet packet,
+at the same time it might be confusing while the packet sniffing as the VLAN header
+does not exist within the packet.
+
+VLAN offloading can be checked by
+.BR ethtool "(8):"
+.in +4
+.sp
+.B ethtool -k
+<phy_dev> |
+.RB grep " tx-vlan-offload"
+.sp
+.in -4
+where <phy_dev> is the physical device to which VLAN device is bound.
+.in -4
 
 .BR gvrp " { " on " | " off " } "
 - specifies whether this VLAN should be registered using GARP VLAN Registration Protocol.
@@ -1065,7 +1089,8 @@ IEEE 802.15.4 device wpan0.
 .SH SEE ALSO
 .br
 .BR ip (8),
-.BR ip-netns (8)
+.BR ip-netns (8),
+.BR ethtool (8)
 
 .SH AUTHOR
 Original Manpage by Michail Litvak <mci@owl.openwall.com>
-- 
2.4.2
