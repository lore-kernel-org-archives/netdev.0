From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH iproute2 json v2 06/27] ip: iplink.c: open/close json obj for ip -brief -json link show dev DEV
Date: Thu, 17 Aug 2017 10:35:53 -0700
Message-ID: <20170817173614.54987-7-julien@cumulusnetworks.com>
References: <20170817173614.54987-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:35122 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753460AbdHQRkk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 13:40:40 -0400
Received: by mail-wr0-f173.google.com with SMTP id 49so41461857wrw.2
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 10:40:40 -0700 (PDT)
In-Reply-To: <20170817173614.54987-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/iplink.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ip/iplink.c b/ip/iplink.c
index 5aff2fde..19bda1b9 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -1041,10 +1041,12 @@ int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
 	if (rtnl_talk(&rth, &req.n, &answer.n, sizeof(answer)) < 0)
 		return -2;
 
+	open_json_object(NULL);
 	if (brief)
 		print_linkinfo_brief(NULL, &answer.n, stdout, NULL);
 	else
 		print_linkinfo(NULL, &answer.n, stdout);
+	close_json_object();
 
 	return 0;
 }
-- 
2.14.1
