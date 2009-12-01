From: Patrick McHardy <kaber@trash.net>
Subject: iplink_vlan: add support for VLAN loose binding flag
Date: Tue, 01 Dec 2009 12:21:39 +0100
Message-ID: <4B14FC43.5010501@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000701060402020509040509"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41060 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752369AbZLALVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 06:21:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000701060402020509040509
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

This patch adds support for the VLAN loose binding flag that is
supported in net-next to iplink_vlan.


--------------000701060402020509040509
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 870970deb6cbea7a5d4881bdd717304d5284d315
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Dec 1 12:21:15 2009 +0100

    iplink_vlan: add support for VLAN loose binding flag
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 2dc4a57..329b354 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -33,6 +33,7 @@ enum vlan_ioctl_cmds {
 enum vlan_flags {
 	VLAN_FLAG_REORDER_HDR	= 0x1,
 	VLAN_FLAG_GVRP		= 0x2,
+	VLAN_FLAG_LOOSE_BINDING	= 0x4,
 };
 
 enum vlan_name_types {
diff --git a/ip/iplink_vlan.c b/ip/iplink_vlan.c
index 9724482..223feb3 100644
--- a/ip/iplink_vlan.c
+++ b/ip/iplink_vlan.c
@@ -27,6 +27,7 @@ static void explain(void)
 		"VLANID := 0-4095\n"
 		"FLAG-LIST := [ FLAG-LIST ] FLAG\n"
 		"FLAG := [ reorder_hdr { on | off } ] [ gvrp { on | off } ]\n"
+		"        [ loose_binding { on | off } ]\n"
 		"QOS-MAP := [ QOS-MAP ] QOS-MAPPING\n"
 		"QOS-MAPPING := FROM:TO\n"
 	);
@@ -102,6 +103,15 @@ static int vlan_parse_opt(struct link_util *lu, int argc, char **argv,
 				flags.flags &= ~VLAN_FLAG_GVRP;
 			else
 				return on_off("gvrp");
+		} else if (matches(*argv, "loose_binding") == 0) {
+			NEXT_ARG();
+			flags.mask |= VLAN_FLAG_LOOSE_BINDING;
+			if (strcmp(*argv, "on") == 0)
+				flags.flags |= VLAN_FLAG_LOOSE_BINDING;
+			else if (strcmp(*argv, "off") == 0)
+				flags.flags &= ~VLAN_FLAG_LOOSE_BINDING;
+			else
+				return on_off("loose_binding");
 		} else if (matches(*argv, "ingress-qos-map") == 0) {
 			NEXT_ARG();
 			if (vlan_parse_qos_map(&argc, &argv, n,
@@ -156,6 +166,7 @@ static void vlan_print_flags(FILE *fp, __u32 flags)
 		}
 	_PF(REORDER_HDR);
 	_PF(GVRP);
+	_PF(LOOSE_BINDING);
 #undef _PF
 	if (flags)
 		fprintf(fp, "%x", flags);

--------------000701060402020509040509--
