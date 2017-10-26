From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2] bridge: fdb: print NDA_SRC_VNI if available
Date: Thu, 26 Oct 2017 10:12:55 -0700
Message-ID: <1509037975-6891-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:54248 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932127AbdJZRNA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 13:13:00 -0400
Received: by mail-pf0-f196.google.com with SMTP id t188so2957574pfd.10
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 10:13:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 bridge/fdb.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index e5cebf9..081233a 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -204,6 +204,15 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				rta_getattr_u32(tb[NDA_VNI]));
 	}
 
+	if (tb[NDA_SRC_VNI]) {
+		if (jw_global)
+			jsonw_uint_field(jw_global, "src_vni",
+					 rta_getattr_u32(tb[NDA_SRC_VNI]));
+		else
+			fprintf(fp, "src_vni %d ",
+				rta_getattr_u32(tb[NDA_SRC_VNI]));
+	}
+
 	if (tb[NDA_IFINDEX]) {
 		unsigned int ifindex = rta_getattr_u32(tb[NDA_IFINDEX]);
 
-- 
2.1.4
