From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH 14/27] ip: iplink_ipoib.c: add json output support
Date: Thu,  3 Aug 2017 17:55:02 +0200
Message-ID: <20170803155515.99226-15-julien@cumulusnetworks.com>
References: <20170803155515.99226-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f179.google.com ([209.85.128.179]:33427 "EHLO
        mail-wr0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751924AbdHCPzu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 11:55:50 -0400
Received: by mail-wr0-f179.google.com with SMTP id v105so7426230wrb.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 08:55:50 -0700 (PDT)
In-Reply-To: <20170803155515.99226-1-julien@cumulusnetworks.com>
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
2.13.3
