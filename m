From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH iproute2 json v2 14/27] ip: iplink_ipoib.c: add json output support
Date: Thu, 17 Aug 2017 10:36:01 -0700
Message-ID: <20170817173614.54987-15-julien@cumulusnetworks.com>
References: <20170817173614.54987-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:37904 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753554AbdHQRlZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 13:41:25 -0400
Received: by mail-wr0-f173.google.com with SMTP id 5so25425237wrz.5
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 10:41:24 -0700 (PDT)
In-Reply-To: <20170817173614.54987-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema:
{
    "key": {
        "type": "string",
        "attr": "IFLA_IPOIB_PKEY"
    },
    "mode": {
        "type": "string",
        "attr": "IFLA_IPOIB_PKEY"
    },
    "umcast": {
        "type": "string",
        "attr": "IFLA_IPOIB_UMCAST"
    }
}

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/iplink_ipoib.c | 30 +++++++++++++++++++++++++-----
 1 file changed, 25 insertions(+), 5 deletions(-)

diff --git a/ip/iplink_ipoib.c b/ip/iplink_ipoib.c
index 86dc65ca..e69bda0e 100644
--- a/ip/iplink_ipoib.c
+++ b/ip/iplink_ipoib.c
@@ -91,23 +91,43 @@ static void ipoib_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	    RTA_PAYLOAD(tb[IFLA_IPOIB_PKEY]) < sizeof(__u16))
 		return;
 
-	fprintf(f, "pkey  %#.4x ", rta_getattr_u16(tb[IFLA_IPOIB_PKEY]));
+	__u16 pkey = rta_getattr_u16(tb[IFLA_IPOIB_PKEY]);
+
+	if (is_json_context()) {
+		SPRINT_BUF(b1);
+
+		snprintf(b1, sizeof(b1), "%#.4x", pkey);
+		print_string(PRINT_JSON, "key", NULL, b1);
+	} else {
+		fprintf(f, "pkey  %#.4x ", pkey);
+	}
 
 	if (!tb[IFLA_IPOIB_MODE] ||
 	    RTA_PAYLOAD(tb[IFLA_IPOIB_MODE]) < sizeof(__u16))
 		return;
 
 	mode = rta_getattr_u16(tb[IFLA_IPOIB_MODE]);
-	fprintf(f, "mode  %s ",
+
+	const char *mode_str =
 		mode == IPOIB_MODE_DATAGRAM ? "datagram" :
-		mode == IPOIB_MODE_CONNECTED ? "connected" :
-		"unknown");
+		mode == IPOIB_MODE_CONNECTED ? "connected" : "unknown";
+
+	print_string(PRINT_ANY, "mode", "mode  %s ", mode_str);
 
 	if (!tb[IFLA_IPOIB_UMCAST] ||
 	    RTA_PAYLOAD(tb[IFLA_IPOIB_UMCAST]) < sizeof(__u16))
 		return;
 
-	fprintf(f, "umcast  %.4x ", rta_getattr_u16(tb[IFLA_IPOIB_UMCAST]));
+	__u16 umcast = rta_getattr_u16(tb[IFLA_IPOIB_UMCAST]);
+
+	if (is_json_context()) {
+		SPRINT_BUF(b1);
+
+		snprintf(b1, sizeof(b1), "%.4x", umcast);
+		print_string(PRINT_JSON, "umcast", NULL, b1);
+	} else {
+		fprintf(f, "umcast  %.4x ", umcast);
+	}
 }
 
 static void ipoib_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.14.1
