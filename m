From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH] vxlan: Fix error that was resulting in VXLAN MTU size being
	10 bytes too large
Date: Fri, 09 Nov 2012 15:35:24 -0800
Message-ID: <20121109233354.17208.36271.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:55812 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751004Ab2KIXfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2012 18:35:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change fixes an issue I found where VXLAN frames were fragmented when
they were up to the VXLAN MTU size.  I root caused the issue to the fact that
the headroom was 4 + 20 + 8 + 8.  This math doesn't appear to be correct
because we are not inserting a VLAN header, but instead a 2nd Ethernet header.
As such the math for the overhead should be 20 + 8 + 8 + 14 to account for the
extra headers that are inserted for VXLAN.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/vxlan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 410ebc8..0b75c19 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -51,8 +51,8 @@
 
 #define VXLAN_N_VID	(1u << 24)
 #define VXLAN_VID_MASK	(VXLAN_N_VID - 1)
-/* VLAN + IP header + UDP + VXLAN */
-#define VXLAN_HEADROOM (4 + 20 + 8 + 8)
+/* IP header + UDP + VXLAN + Ethernet header */
+#define VXLAN_HEADROOM (20 + 8 + 8 + 14)
 
 #define VXLAN_FLAGS 0x08000000	/* struct vxlanhdr.vx_flags required value. */
 
