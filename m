From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH iproute2 json v2 15/27] ip: iplink_ipvlan.c: add json output support
Date: Thu, 17 Aug 2017 10:36:02 -0700
Message-ID: <20170817173614.54987-16-julien@cumulusnetworks.com>
References: <20170817173614.54987-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:37927 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753563AbdHQRl2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 13:41:28 -0400
Received: by mail-wr0-f176.google.com with SMTP id 5so25426378wrz.5
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 10:41:27 -0700 (PDT)
In-Reply-To: <20170817173614.54987-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema:
{
    "mode": {
        "type": "string",
        "attr": "IFLA_IPVLAN_MODE"
    }
}

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/iplink_ipvlan.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/ip/iplink_ipvlan.c b/ip/iplink_ipvlan.c
index f7735f3a..9f48309e 100644
--- a/ip/iplink_ipvlan.c
+++ b/ip/iplink_ipvlan.c
@@ -68,11 +68,11 @@ static void ipvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_IPVLAN_MODE]) {
 		if (RTA_PAYLOAD(tb[IFLA_IPVLAN_MODE]) == sizeof(__u16)) {
 			__u16 mode = rta_getattr_u16(tb[IFLA_IPVLAN_MODE]);
-
-			fprintf(f, " mode %s ",
-				mode == IPVLAN_MODE_L2 ? "l2" :
+			const char *mode_str = mode == IPVLAN_MODE_L2 ? "l2" :
 				mode == IPVLAN_MODE_L3 ? "l3" :
-				mode == IPVLAN_MODE_L3S ? "l3s" : "unknown");
+				mode == IPVLAN_MODE_L3S ? "l3s" : "unknown";
+
+			print_string(PRINT_ANY, "mode", " mode %s ", mode_str);
 		}
 	}
 }
-- 
2.14.1
