From: Ed Swierk <eswierk@bigswitch.com>
Subject: bridge: allow forwarding LLDP frames
Date: Mon, 17 Oct 2011 11:12:07 -0700 (PDT)
Message-ID: <20111017181207.06081E3280@meep>
To: <shemminger@vyatta.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <eswierk@bigswitch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c-98-248-32-191.hsd1.ca.comcast.net ([98.248.32.191]:59813 "EHLO
	meep" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751198Ab1JQSUg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 14:20:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LLDP frames have reserved destination MAC address 01-80-C2-00-00-0E,
which by default are not forwarded by 802.1d-compliant bridges.

In certain situations, like when creating a transparent link-layer
relay between a pair of interfaces, it may be useful to configure a
bridge interface to forward LLDP and other control frames in the
01-80-C2-00-00-xx range rather than filtering them.

Stephen Hemminger's recent patch allows the user to set a sysfs
attribute /sys/class/net/brX/bridge/group_fwd_mask to enable
forwarding of normally filtered addresses, with certain exceptions.
This patch eliminates the restriction on LLDP frames, allowing the
user to override the default behavior of filtering them.

Signed-off-by: Ed Swierk <eswierk@bigswitch.com>

---

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index a248fe6..b016dd8 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -31,8 +31,8 @@
 
 /* Control of forwarding link local multicast */
 #define BR_GROUPFWD_DEFAULT	0
-/* Don't allow forwarding control protocols like STP and LLDP */
-#define BR_GROUPFWD_RESTRICTED	0x4007u
+/* Don't allow forwarding control protocols like STP */
+#define BR_GROUPFWD_RESTRICTED	0x0007u
 
 /* Path to usermode spanning tree program */
 #define BR_STP_PROG	"/sbin/bridge-stp"
