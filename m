From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH RFC v2 iproute2] iplink_vlan: Add flag for Multiple VLAN Registration Protocol (MVRP)
Date: Thu, 7 Feb 2013 22:50:57 -0500
Message-ID: <1360295457-5245-4-git-send-email-david.ward@ll.mit.edu>
References: <1360295457-5245-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:39182 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756979Ab3BHEOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2013 23:14:44 -0500
In-Reply-To: <1360295457-5245-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 include/linux/if_vlan.h |    1 +
 ip/iplink_vlan.c        |   12 +++++++++++-
 2 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 3be1ca6..24ae007 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -34,6 +34,7 @@ enum vlan_flags {
 	VLAN_FLAG_REORDER_HDR	= 0x1,
 	VLAN_FLAG_GVRP		= 0x2,
 	VLAN_FLAG_LOOSE_BINDING	= 0x4,
+	VLAN_FLAG_MVRP		= 0x8,
 };
 
 enum vlan_name_types {
diff --git a/ip/iplink_vlan.c b/ip/iplink_vlan.c
index 97af8d6..4d155b6 100644
--- a/ip/iplink_vlan.c
+++ b/ip/iplink_vlan.c
@@ -26,7 +26,7 @@ static void explain(void)
 		"\n"
 		"VLANID := 0-4095\n"
 		"FLAG-LIST := [ FLAG-LIST ] FLAG\n"
-		"FLAG := [ reorder_hdr { on | off } ] [ gvrp { on | off } ]\n"
+		"FLAG := [ reorder_hdr { on | off } ] [ gvrp { on | off } ] [ mvrp { on | off } ]\n"
 		"        [ loose_binding { on | off } ]\n"
 		"QOS-MAP := [ QOS-MAP ] QOS-MAPPING\n"
 		"QOS-MAPPING := FROM:TO\n"
@@ -103,6 +103,15 @@ static int vlan_parse_opt(struct link_util *lu, int argc, char **argv,
 				flags.flags &= ~VLAN_FLAG_GVRP;
 			else
 				return on_off("gvrp");
+		} else if (matches(*argv, "mvrp") == 0) {
+			NEXT_ARG();
+			flags.mask |= VLAN_FLAG_MVRP;
+			if (strcmp(*argv, "on") == 0)
+				flags.flags |= VLAN_FLAG_MVRP;
+			else if (strcmp(*argv, "off") == 0)
+				flags.flags &= ~VLAN_FLAG_MVRP;
+			else
+				return on_off("mvrp");
 		} else if (matches(*argv, "loose_binding") == 0) {
 			NEXT_ARG();
 			flags.mask |= VLAN_FLAG_LOOSE_BINDING;
@@ -166,6 +175,7 @@ static void vlan_print_flags(FILE *fp, __u32 flags)
 		}
 	_PF(REORDER_HDR);
 	_PF(GVRP);
+	_PF(MVRP);
 	_PF(LOOSE_BINDING);
 #undef _PF
 	if (flags)
-- 
1.7.1
