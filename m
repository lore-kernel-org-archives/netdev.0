From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH 09/27] ip: iplink_hsr.c: add json output support
Date: Thu,  3 Aug 2017 17:54:57 +0200
Message-ID: <20170803155515.99226-10-julien@cumulusnetworks.com>
References: <20170803155515.99226-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:34815 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751209AbdHCPzo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 11:55:44 -0400
Received: by mail-wr0-f181.google.com with SMTP id 12so7404613wrb.1
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 08:55:44 -0700 (PDT)
In-Reply-To: <20170803155515.99226-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema:
hsr: IFLA_INFO_DATA
{
    "slave1": {
        "type": "string",
        "attr": "IFLA_HSR_SLAVE1"
    },
    "slave2": {
        "type": "string",
        "attr": "IFLA_HSR_SLAVE2"
    },
    "seq_nr": {
        "type": "int",
        "attr": "IFLA_HSR_SEQ_NR"
    },
    "supervision_addr": {
        "type": "int",
        "attr": "IFLA_HSR_SUPERVISION_ADDR"
    }
}

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/iplink_hsr.c | 36 +++++++++++++++++++++---------------
 1 file changed, 21 insertions(+), 15 deletions(-)

diff --git a/ip/iplink_hsr.c b/ip/iplink_hsr.c
index 696b2c91..c673ccf7 100644
--- a/ip/iplink_hsr.c
+++ b/ip/iplink_hsr.c
@@ -110,30 +110,36 @@ static void hsr_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	    RTA_PAYLOAD(tb[IFLA_HSR_SUPERVISION_ADDR]) < ETH_ALEN)
 		return;
 
-	fprintf(f, "slave1 ");
 	if (tb[IFLA_HSR_SLAVE1])
-		fprintf(f, "%s ",
-			ll_index_to_name(rta_getattr_u32(tb[IFLA_HSR_SLAVE1])));
+		print_string(PRINT_ANY,
+			     "slave1",
+			     "slave1 %s ",
+			     ll_index_to_name(rta_getattr_u32(tb[IFLA_HSR_SLAVE1])));
 	else
-		fprintf(f, "<none> ");
+		print_null(PRINT_ANY, "slave1", "slave1 %s ", "<none>");
 
-	fprintf(f, "slave2 ");
 	if (tb[IFLA_HSR_SLAVE2])
-		fprintf(f, "%s ",
-			ll_index_to_name(rta_getattr_u32(tb[IFLA_HSR_SLAVE2])));
+		print_string(PRINT_ANY,
+			     "slave2",
+			     "slave2 %s ",
+			     ll_index_to_name(rta_getattr_u32(tb[IFLA_HSR_SLAVE2])));
 	else
-		fprintf(f, "<none> ");
+		print_null(PRINT_ANY, "slave2", "slave2 %s ", "<none>");
 
 	if (tb[IFLA_HSR_SEQ_NR])
-		fprintf(f, "sequence %d ",
-			rta_getattr_u16(tb[IFLA_HSR_SEQ_NR]));
+		print_int(PRINT_ANY,
+			  "seq_nr",
+			  "sequence %d ",
+			  rta_getattr_u16(tb[IFLA_HSR_SEQ_NR]));
 
 	if (tb[IFLA_HSR_SUPERVISION_ADDR])
-		fprintf(f, "supervision %s ",
-			ll_addr_n2a(RTA_DATA(tb[IFLA_HSR_SUPERVISION_ADDR]),
-				    RTA_PAYLOAD(tb[IFLA_HSR_SUPERVISION_ADDR]),
-				    ARPHRD_VOID,
-				    b1, sizeof(b1)));
+		print_string(PRINT_ANY,
+			     "supervision_addr",
+			     "supervision %s ",
+			     ll_addr_n2a(RTA_DATA(tb[IFLA_HSR_SUPERVISION_ADDR]),
+					 RTA_PAYLOAD(tb[IFLA_HSR_SUPERVISION_ADDR]),
+					 ARPHRD_VOID,
+					 b1, sizeof(b1)));
 }
 
 static void hsr_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.13.3
