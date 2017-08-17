From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH iproute2 json v2 16/27] ip: iplink_vrf.c: add json output support
Date: Thu, 17 Aug 2017 10:36:03 -0700
Message-ID: <20170817173614.54987-17-julien@cumulusnetworks.com>
References: <20170817173614.54987-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:34030 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753577AbdHQRlb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 13:41:31 -0400
Received: by mail-wr0-f181.google.com with SMTP id y96so47241782wrc.1
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 10:41:31 -0700 (PDT)
In-Reply-To: <20170817173614.54987-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema:
{
    "table": {
        "type": "uint",
        "attr": "IFLA_VRF_TABLE"
    }
}

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/iplink_vrf.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/ip/iplink_vrf.c b/ip/iplink_vrf.c
index 917630e8..f13b1d24 100644
--- a/ip/iplink_vrf.c
+++ b/ip/iplink_vrf.c
@@ -62,7 +62,10 @@ static void vrf_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		return;
 
 	if (tb[IFLA_VRF_TABLE])
-		fprintf(f, "table %u ", rta_getattr_u32(tb[IFLA_VRF_TABLE]));
+		print_uint(PRINT_ANY,
+			   "table",
+			   "table %u ",
+			   rta_getattr_u32(tb[IFLA_VRF_TABLE]));
 }
 
 static void vrf_slave_print_opt(struct link_util *lu, FILE *f,
@@ -72,13 +75,15 @@ static void vrf_slave_print_opt(struct link_util *lu, FILE *f,
 		return;
 
 	if (tb[IFLA_VRF_PORT_TABLE]) {
-		fprintf(f, "table %u ",
-			rta_getattr_u32(tb[IFLA_VRF_PORT_TABLE]));
+		print_uint(PRINT_ANY,
+			   "table",
+			   "table %u ",
+			   rta_getattr_u32(tb[IFLA_VRF_PORT_TABLE]));
 	}
 }
 
 static void vrf_print_help(struct link_util *lu, int argc, char **argv,
-			      FILE *f)
+			   FILE *f)
 {
 	vrf_explain(f);
 }
-- 
2.14.1
