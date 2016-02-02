From: David Ahern <dsa@cumulusnetworks.com>
Subject: [iproute2 net-next] vrf: Add support for slave_info
Date: Tue,  2 Feb 2016 07:43:46 -0800
Message-ID: <1454427826-6444-2-git-send-email-dsa@cumulusnetworks.com>
References: <1454427826-6444-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:32838 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933354AbcBBPoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 10:44:01 -0500
Received: by mail-pf0-f173.google.com with SMTP id w123so14383599pfb.0
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 07:44:01 -0800 (PST)
In-Reply-To: <1454427826-6444-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print VRF slave_info attributes if present.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
Requires IFLA_VRF_PORT_* from linux/if_link.h

 ip/iplink_vrf.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/ip/iplink_vrf.c b/ip/iplink_vrf.c
index 9b4b7728cf6f..abc796886a5f 100644
--- a/ip/iplink_vrf.c
+++ b/ip/iplink_vrf.c
@@ -64,6 +64,18 @@ static void vrf_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		fprintf(f, "table %u ", rta_getattr_u32(tb[IFLA_VRF_TABLE]));
 }
 
+static void vrf_slave_print_opt(struct link_util *lu, FILE *f,
+				struct rtattr *tb[])
+{
+	if (!tb)
+		return;
+
+	if (tb[IFLA_VRF_PORT_TABLE]) {
+		fprintf(f, "table %u ",
+			rta_getattr_u32(tb[IFLA_VRF_PORT_TABLE]));
+	}
+}
+
 static void vrf_print_help(struct link_util *lu, int argc, char **argv,
 			      FILE *f)
 {
@@ -77,3 +89,10 @@ struct link_util vrf_link_util = {
 	.print_opt	= vrf_print_opt,
 	.print_help	= vrf_print_help,
 };
+
+struct link_util vrf_slave_link_util = {
+        .id             = "vrf",
+        .maxattr        = IFLA_VRF_PORT_MAX,
+	.print_opt	= vrf_slave_print_opt,
+        .slave          = true,
+};
-- 
2.1.4
