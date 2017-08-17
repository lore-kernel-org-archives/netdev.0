From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH iproute2 json v2 18/27] ip: iplink_xdp.c: add json output support
Date: Thu, 17 Aug 2017 10:36:05 -0700
Message-ID: <20170817173614.54987-19-julien@cumulusnetworks.com>
References: <20170817173614.54987-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f179.google.com ([209.85.128.179]:34085 "EHLO
        mail-wr0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753595AbdHQRlj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 13:41:39 -0400
Received: by mail-wr0-f179.google.com with SMTP id y96so47244372wrc.1
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 10:41:38 -0700 (PDT)
In-Reply-To: <20170817173614.54987-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema
{
    "attached": {
        "type": "uint",
        "attr": "IFLA_XDP_ATTACHED"
    },
    "prog_id": {
        "type": "uint",
        "attr": "IFLA_XDP_PROG_ID"
    }
}

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/iplink_xdp.c | 31 ++++++++++++++++++-------------
 1 file changed, 18 insertions(+), 13 deletions(-)

diff --git a/ip/iplink_xdp.c b/ip/iplink_xdp.c
index 9ae9ee5d..3a61076e 100644
--- a/ip/iplink_xdp.c
+++ b/ip/iplink_xdp.c
@@ -16,6 +16,7 @@
 
 #include "xdp.h"
 #include "bpf_util.h"
+#include "ip_common.h"
 
 extern int force;
 
@@ -92,20 +93,24 @@ void xdp_dump(FILE *fp, struct rtattr *xdp)
 		return;
 
 	mode = rta_getattr_u8(tb[IFLA_XDP_ATTACHED]);
-	if (mode == XDP_ATTACHED_NONE)
-		return;
-	else if (mode == XDP_ATTACHED_DRV)
-		fprintf(fp, "xdp");
-	else if (mode == XDP_ATTACHED_SKB)
-		fprintf(fp, "xdpgeneric");
-	else if (mode == XDP_ATTACHED_HW)
-		fprintf(fp, "xdpoffload");
-	else
-		fprintf(fp, "xdp[%u]", mode);
+	if (is_json_context()) {
+		print_uint(PRINT_JSON, "attached", NULL, mode);
+	} else {
+		if (mode == XDP_ATTACHED_NONE)
+			return;
+		else if (mode == XDP_ATTACHED_DRV)
+			fprintf(fp, "xdp");
+		else if (mode == XDP_ATTACHED_SKB)
+			fprintf(fp, "xdpgeneric");
+		else if (mode == XDP_ATTACHED_HW)
+			fprintf(fp, "xdpoffload");
+		else
+			fprintf(fp, "xdp[%u]", mode);
+	}
 
 	if (tb[IFLA_XDP_PROG_ID])
-		fprintf(fp, "/id:%u",
-			rta_getattr_u32(tb[IFLA_XDP_PROG_ID]));
+		print_uint(PRINT_ANY, "prog_id", "/id:%u",
+				   rta_getattr_u32(tb[IFLA_XDP_PROG_ID]));
 
-	fprintf(fp, " ");
+	print_string(PRINT_FP, NULL, "%c", " ");
 }
-- 
2.14.1
