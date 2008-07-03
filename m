From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE]: iflink_vlan: support GVRP flag
Date: Thu, 03 Jul 2008 19:06:29 +0200
Message-ID: <486D0715.9090902@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020301050508050409000808"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42907 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752672AbYGCRGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 13:06:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020301050508050409000808
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This is the patch for iproute for configuring GVRP.



--------------020301050508050409000808
Content-Type: text/x-diff;
 name="iproute-gvrp.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="iproute-gvrp.diff"

commit 32143eed8b706e5c6554ab42903533b3bccdc060
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Jul 3 19:05:09 2008 +0200

    [IPROUTE]: iflink_vlan: support GVRP flag
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 4014ba9..2dc4a57 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -32,6 +32,7 @@ enum vlan_ioctl_cmds {
 
 enum vlan_flags {
 	VLAN_FLAG_REORDER_HDR	= 0x1,
+	VLAN_FLAG_GVRP		= 0x2,
 };
 
 enum vlan_name_types {
diff --git a/ip/iplink_vlan.c b/ip/iplink_vlan.c
index 1964839..9724482 100644
--- a/ip/iplink_vlan.c
+++ b/ip/iplink_vlan.c
@@ -26,7 +26,7 @@ static void explain(void)
 		"\n"
 		"VLANID := 0-4095\n"
 		"FLAG-LIST := [ FLAG-LIST ] FLAG\n"
-		"FLAG := [ reorder_hdr { on | off } ]\n"
+		"FLAG := [ reorder_hdr { on | off } ] [ gvrp { on | off } ]\n"
 		"QOS-MAP := [ QOS-MAP ] QOS-MAPPING\n"
 		"QOS-MAPPING := FROM:TO\n"
 	);
@@ -93,6 +93,15 @@ static int vlan_parse_opt(struct link_util *lu, int argc, char **argv,
 				flags.flags &= ~VLAN_FLAG_REORDER_HDR;
 			else
 				return on_off("reorder_hdr");
+		} else if (matches(*argv, "gvrp") == 0) {
+			NEXT_ARG();
+			flags.mask |= VLAN_FLAG_GVRP;
+			if (strcmp(*argv, "on") == 0)
+				flags.flags |= VLAN_FLAG_GVRP;
+			else if (strcmp(*argv, "off") == 0)
+				flags.flags &= ~VLAN_FLAG_GVRP;
+			else
+				return on_off("gvrp");
 		} else if (matches(*argv, "ingress-qos-map") == 0) {
 			NEXT_ARG();
 			if (vlan_parse_qos_map(&argc, &argv, n,
@@ -146,6 +155,7 @@ static void vlan_print_flags(FILE *fp, __u32 flags)
 			fprintf(fp, #f "%s", flags ? "," : ""); \
 		}
 	_PF(REORDER_HDR);
+	_PF(GVRP);
 #undef _PF
 	if (flags)
 		fprintf(fp, "%x", flags);

--------------020301050508050409000808--
